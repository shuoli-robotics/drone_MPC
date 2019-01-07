clear
clear global
clc
close all


 t0 = 0;
 deltaT = 3;

simTime = 10;
step = 0.01;
time = zeros(simTime/step,1);
states = zeros(simTime/step,4);
inputs = zeros(simTime/step,2);
states(1,:) = [0 -1 0 0];

 pos_constrain = [states(1,2)+0.3 0];
 vel_constrain = [states(1,4)-0.3 0];
 acc_constrain = [0 0];

 kp = 1;
 kd = 0.5;
 ki = 0.000;
 sum_error = 0.0;
[P_min,P_vel_min,P_tan_phi_min,t_min] = minimize_time(pos_constrain,vel_constrain,acc_constrain,0); 

for i = 1:simTime/step-1
   time(i) = step*(i-1);
   pos_est = states(i,1:2)+(-1)^round(rand())*(0.2*rand(1,2));
   vel_est = states(i,3:4)+(-1)^round(rand())*(0.1*rand(1,2));
   position_error = get_value_from_coefficient(P_min,time(i))-pos_est(2);
   vel_error = get_value_from_coefficient(P_vel_min,time(i))-vel_est(2);
   sum_error = sum_error + vel_error*step;
   if time(i) < t_min
      % use ff + fb
      phi_ff = atan(get_value_from_coefficient(P_tan_phi_min,time(i)));
      phi_fb_p = kp*(get_value_from_coefficient(P_min,time(i))-pos_est(2));
      phi_fb_d = kd*(get_value_from_coefficient(P_vel_min,time(i))-vel_est(2));
      phi_fb_i = ki * sum_error;
      phi_cmd = phi_ff+phi_fb_p+phi_fb_d+phi_fb_i;
   else
      phi_fb_p = kp*(0.0-pos_est(2));
      phi_fb_d = kd*(0.0-vel_est(2));
      phi_fb_i = ki * sum_error;
      phi_cmd = phi_fb_p+phi_fb_d+phi_fb_i;
   end
   
   inputs(i,:) = [phi_cmd,0.0];
   dx = drone_model(states(i,:),inputs(i,:));
   states(i+1,:) = states(i,:) + dx' *step;
end
time(end) = time(end-1);
figure(5)
subplot(2,1,1)
plot(time,states(:,2));
xlabel('time[s]');
ylabel('y[m]')
subplot(2,1,2)
plot(time,inputs(:,1)/pi*180);
xlabel('time[s]');
ylabel('phi[deg]')
temp = 1;