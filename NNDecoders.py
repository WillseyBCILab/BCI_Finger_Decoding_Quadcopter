import torch
import torch.nn as nn
import torch.nn.functional as F
import torch.optim as optim
from torch.utils.data import DataLoader
from torch.utils.data import sampler
import scipy.io as sio
import numpy as np
from torch.utils.data import Dataset, DataLoader
import torchvision.datasets as dset
import torchvision.transforms as T


def flatten(x, start_dim=1, end_dim=-1):
    return x.flatten(start_dim=start_dim, end_dim=end_dim)


class LayerModel(nn.Module):
    def __init__(self, inputSize, outputSize):
        super(LayerModel, self).__init__()

        self.fc = nn.Linear(inputSize, outputSize)
        nn.init.kaiming_normal_(self.fc.weight, nonlinearity='relu')
        nn.init.zeros_(self.fc.bias)
        self.do = nn.Dropout(p=0.5)
        self.bn = nn.BatchNorm1d(outputSize)

    def forward(self, x):
        y = F.relu(self.bn(self.do(self.fc(x))))
        return y

class AllLayers(nn.Module):
    def __init__(self,hiddenSize,layerNum):
        super(AllLayers, self).__init__()
        self.layers = nn.ModuleList([LayerModel(hiddenSize,hiddenSize) for i in range(layerNum)])

    def forward(self, x):
        # ModuleList can act as an iterable, or be indexed using ints
        x_n = []
        for i in enumerate(self.layers):
            x = self.layers[i[0]](x)
            x_n += [x]
        x_n = x_n[0:-1]
        return x, x_n


class FF_CN_FC_SBP(nn.Module):
    def __init__(self, input_size, hidden_size, FClayerNum, ConvSize, ConvSizeOut, num_states, bias_option=2):
        super().__init__()
        # assign layer objects to class attributes

        self.bias_option = bias_option

        self.bn0 = nn.BatchNorm1d(input_size)

        self.cn = nn.Conv1d(ConvSize, ConvSizeOut, 1, bias=True)
        nn.init.kaiming_normal_(self.cn.weight, nonlinearity='relu')
        nn.init.zeros_(self.cn.bias)
        self.bn_cn = nn.BatchNorm1d(input_size * ConvSizeOut)

        self.Lay1 = LayerModel(input_size * ConvSizeOut, hidden_size)
        self.hiddenLayers = AllLayers(hidden_size, FClayerNum-2)
        self.LinF = nn.Linear(hidden_size, num_states, bias=False)
        nn.init.kaiming_normal_(self.LinF.weight, nonlinearity='relu')
        self.bnF = nn.BatchNorm1d(num_states,affine=False)

    def forward(self, x, BadChannels=[]):

        # forward always defines connectivity
        x[:, BadChannels, :] = 0

        x = self.bn0(x)

        x = self.cn(x.permute(0, 2, 1))
        x = F.relu(self.bn_cn(flatten(x)))


        x = self.Lay1(x)
        x, _ = self.hiddenLayers(x)
        x = self.LinF(x)

        # option 1 - This will essentially try to normalize out the mean and standard deviation, repeated refits will not kill the bias for x because it is allowed to learn a bias
        if self.bias_option == 1:
            scores = self.bnF(x)

        # option 2 - This will allow for a mean; this requires multiple retrains with reFIT to kill the bias
        elif self.bias_option == 2:
            with torch.no_grad():
                self.bnF.running_mean.data = torch.zeros_like(self.bnF.running_mean)
                if self.bnF.training:
                    mean_orig = torch.mean(x,dim=0)
                    std_orig = torch.std(x,dim=0)+torch.sqrt(torch.tensor(self.bnF.eps))
                    constant = mean_orig/std_orig
                else:
                    constant = 0
            scores = self.bnF(x) + constant

        # option 3 - this will normalize out the mean for training but will allow the bias during eval mode
        elif self.bias_option == 3:
            self.bnF.running_mean.data = torch.zeros_like(self.bnF.running_mean)
            scores = self.bnF(x)

        return scores


class FF_CN_FC_SBP_Analyze(nn.Module):
    def __init__(self, input_size, hidden_size, FClayerNum, ConvSize, ConvSizeOut, num_states, bias_option=2):
        super().__init__()
        # assign layer objects to class attributes

        self.bias_option = bias_option

        self.bn0 = nn.BatchNorm1d(input_size)

        self.cn = nn.Conv1d(ConvSize, ConvSizeOut, 1, bias=True)
        nn.init.kaiming_normal_(self.cn.weight, nonlinearity='relu')
        nn.init.zeros_(self.cn.bias)
        self.bn_cn = nn.BatchNorm1d(input_size * ConvSizeOut)

        self.Lay1 = LayerModel(input_size * ConvSizeOut, hidden_size)
        self.hiddenLayers = AllLayers(hidden_size, FClayerNum-2)
        self.LinF = nn.Linear(hidden_size, num_states,bias=False)
        nn.init.kaiming_normal_(self.LinF.weight, nonlinearity='relu')
        self.bnF = nn.BatchNorm1d(num_states,affine=False)

    def forward(self, x, BadChannels=[]):
        # forward always defines connectivity
        x_nodes = []

        x[:, BadChannels, :] = 0

        x = self.bn0(x)

        x = self.cn(x.permute(0, 2, 1))
        x = F.relu(self.bn_cn(flatten(x)))
        x_nodes += [x] 

        x = self.Lay1(x)
        x_nodes += [x] 

        x, x_nodes_1 = self.hiddenLayers(x)
        x_nodes += x_nodes_1
        x_nodes += [x] 

        x = self.LinF(x)
        x_nodes += [x] 

        # option 1 - This will essentially try to normalize out the mean and standard deviation, repeated refits will not kill the bias for x because it is allowed to learn a bias
        if self.bias_option == 1:
            scores = self.bnF(x)

        # option 2 - This will allow for a mean; this requires multiple retrains with reFIT to kill the bias
        elif self.bias_option == 2:
            with torch.no_grad():
                self.bnF.running_mean.data = torch.zeros_like(self.bnF.running_mean)
                if self.bnF.training:
                    mean_orig = torch.mean(x,dim=0)
                    std_orig = torch.std(x,dim=0)+torch.sqrt(torch.tensor(self.bnF.eps))
                    constant = mean_orig/std_orig
                else:
                    constant = 0
            scores = self.bnF(x) + constant

        # option 3 - this will normalize out the mean for training but will allow the bias during eval mode, with multiple refits
        elif self.bias_option == 3:
            self.bnF.running_mean.data = torch.zeros_like(self.bnF.running_mean)
            scores = self.bnF(x)

        return scores, x_nodes

