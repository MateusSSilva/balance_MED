
function [cir,vel,wv,wr]=fitHoff(t,r,dr)
if(isempty(t))
    cir=[];vel=[];w=0;
    return
end
dt=t(end)-t(1);     % Duration
D=r(end)-r(1);      % Displacement
ro=r(1);            % initial position
to=t(1);            % initial time
siz=length(t);
rm=0;
for i=1:siz
    x=(t(i)-to)/dt;
      cir(i)=ro+D*(6*(x^5)-15*(x^4)+10*(x^3));      %model Hoff position
      vel(i)=D/dt*30*( (x^4) -2*(x^3) + (x^2) );    %model Hoff velocity
    
%     cir(i)=ro+D/2*(1-cos(pi()*(t(i)-to)/dt));       %model position
%     vel(i)=D*pi()/(2*dt)*sin((t(i)-to)*pi()/dt);    %model velocity

    vmr(i)=real(pi()*D/(2*dt)*sin(acos(1-2*(r(i)-ro)/D)));  %model velociy aligned with r
    %rm=rm+abs(dr(i)-vel(i)); %sqrt((r(i)-cir(i))^2 + (dr(i)-vel(i))^2);
end
dv=(vel'-dr);
wv=std(dv)/abs(mean(dr));
wr=sum(abs(cir'-r))/siz;
end
