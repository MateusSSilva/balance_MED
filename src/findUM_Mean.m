function [Nb,R,VMean,Du,w,Ppb,xm,vm,Bpt,En,CutTime]=findUM_mean(t,d,v,limD,limT,Ev,fs)
    Nb=0;R=[];VMean=[];Du=[];w=[];Ppb=[];xm=[];vm=[];Bpt=0;En=[];
    [sI,sF]=segment2(t,d,v,limD,limT,Ev);
    if isempty(sI)
        vm=zeros(length(t),1);
        return;
    end
    Nb=length(sI);
    Bpt=Nb/(t(end)-t(1));     %% bullets per time, considere only time between the first and last bullet
    R=zeros(Nb,1);VMean=zeros(Nb,1);Du=zeros(Nb,1);w=zeros(Nb,1);En=zeros(Nb,1);
    xm=zeros(length(t),1);vm=xm;
    Ppb=zeros(Nb,1);        %% spikes per bullets
    for i=1:Nb
       [b,vb,w(i)]=fitHoff(t(sI(i):sF(i)),d(sI(i):sF(i)),v(sI(i):sF(i)));
       R(i)=d(sF(i))-d(sI(i));
       if abs(R(i)) < limD
           disp('stop');
           debug(); 
       end
       xm(sI(i):sF(i))=b;
       vm(sI(i):sF(i))=vb;
       VMean(i)=mean(abs(v(sI(i):sF(i))));
       Du(i)=t(sF(i))-t(sI(i));
       Ppb(i)=getPeaks(t(sI(i):sF(i)),abs(v(sI(i):sF(i))),Ev);
       En(i) = trapz(d(sI(i):sF(i)),v(sI(i):sF(i)))/Du(i);
    end
    CutTime=sum(sI(2:end)-sF(1:end-1))/fs;
end

