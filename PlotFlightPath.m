function PlotFlightPath(tt)

% Plots the Saved Exemplar Flight Path

load('..\Data\20230712\RedisMat\t5_t5.2023.07.12_Data_RedisMat_20230712_151106_(14).mat')

if nargin == 1
    x = x(tt);
    y = y(tt);
    z = z(tt);
end

plot3(x,y,-z,'Color','#00843D','LineWidth',2)
grid on
zlabel('Elevation')
xlabel('Long Axis of Court')
ylabel('Short Axis of Court')
set(gca,'XLabel',[])
set(gca,'YLabel',[])
set(gca,'ZLabel',[])
set(gca,'XTickLabel',[])
set(gca,'YTickLabel',[])
set(gca,'ZTickLabel',[])
hold on
set(gca,'View',[-128   29])

r1_center = [-134.13, 20.80, 14.91];
r2_center = [-178.77, 20.80, 14.91];
ring_rad = 6.75;
ringY = [-ring_rad:.01:ring_rad].';
ringZ = sqrt(ring_rad.^2-ringY.^2);
ringZ = [ringZ;-ringZ];
ringY = [ringY;ringY];

ring1 = [r1_center(1)*ones(size(ringY,1),1) r1_center(2)+ringY r1_center(3)+ringZ];
plot3(ring1(:,1),ring1(:,2),ring1(:,3),'.','Color','#CC5500','MarkerSize',5)

ring2 = [r2_center(1)*ones(size(ringY,1),1) r2_center(2)+ringY r2_center(3)+ringZ];
plot3(ring2(:,1),ring2(:,2),ring2(:,3),'.','Color','#CC5500','MarkerSize',5)

xlim([-200, -100])
ylim([0, 45])
zlim([5, 35])

return