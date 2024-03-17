function MED_balance(dirName,output,flg_jovens,filtro_frequencia,D_min,T_min,V_min)
    [files]=dir([dirName '\*.xlsx']);
    numbOfFiles=length(files);
    p=fopen(output,'wt');
    l='arq;Tarefa;Duracao;Trajetoria;VelMedia;VelMax;VxMedio;Vymedio;Nx;Ny;Nb;alfa;alfax;alfay;Int;Intx;Inty;R2;DmX;DmY;Dm;VmX;VmY;Vm;StdRx;StdRy;DurX;DurY;CvX;CvY;RxMax;RyMax;RMax;RxMin;RyMin;RMin;VxMax;VyMax;VMax;VxMin;VyMin;VMin;int12;cutTimeX;cutTimeY';
    fprintf(p,'%s\n',l);

    Int=0;
    Alfa=0;
    for k=1:numbOfFiles
        fileName=files(k).name;
        fileNamePath=[dirName fileName];
        [arq,tar]=extractName(fileName);
        fileData=readtable(fileNamePath);
        fileData=fileData{:,:};
        disp([fileName '-' num2str(k/numbOfFiles*100,2) '%' ]);
        Inta=Int;
        Alfaa=Alfa;
        if flg_jovens
            fileData=fileData(1:4:3569,:);
        end
        t=fileData(:,2);
        x=fileData(:,5);
        y=fileData(:,6);
        fs=1/(t(2)-t(1));
        pi=5/fs;   %% ponto inicial em segundos
        pf=5/fs;   %% corte final em segundos
        [b,a] = butter(4, filtro_frequencia / (fs/2)); %low pass filter
        x=filtfilt(b,a, x);
        y=filtfilt(b,a, y);
        vx=diff(x)*fs;
        vy=diff(y)*fs;
        x=x(1:end-1);
        y=y(1:end-1);
        cutDataX=x(int32(pi*fs):int32(end-pf*fs));
        cutDataY=y(int32(pi*fs):int32(end-pf*fs));
        t=t(int32(pi*fs):int32(end-pf*fs-1));
        Vx=vx(int32(pi*fs):int32(end-pf*fs));
        Vy=vy(int32(pi*fs):int32(end-pf*fs));
        V=sqrt(Vx.*Vx+Vy.*Vy);
        duracao=abs(t(end)-t(1));
        traj=sum(sqrt((Vx./fs).^2+(Vy./fs).^2));
      
        [Nx,Ny,Nb,Alfa,Alfax,Alfay,Int,Intx,Inty,RmX,RmY,Rm,VmX,VmY,Vm,stdRx,stdRy,Dux,Duy,~,R2,RxMax,RyMax,RMax,RxMin,RyMin,RMin,VxMax,VyMax,VMax,VxMin,VyMin,VMin,cutTimex,cutTimey]=Bullets(cutDataX,cutDataY,Vx,Vy,t,D_min,T_min,V_min,fs);
        cvX=std(cutDataX)/mean(cutDataX);
        cvY=std(cutDataY)/mean(cutDataY);
        
        if(mod(k,2)==0)
            int12=exp((log(Int)-log(Inta))/(Alfaa-Alfa));
        else
            int12=NaN;
        end
        %% ---------------------    
  %%arq;Tarefa;duracao;Trajetoria;VelMedia;VelMax;VxMedio;Vymedio;Nx;Ny;Nb;alfa;Int;R2;RmX;RmY;Rm;VmX;VmY;Vm;StdRx;StdRy;DurX;DurY;CvX;CvY;RxMax;RyMax;RMax;RxMin;RyMin;RMin;VxMax;VyMax;VMax;VxMin;VyMin;VMin;int12';
        l=[arq ';' tar ';' num2str(duracao) ';' num2str(traj) ';'...
            num2str(mean(V)) ';' num2str(max(V)) ';' ...
            num2str(mean(abs(Vx))) ';' num2str(mean(abs(Vy))) ';' ...
            num2str(Nx) ';' num2str(Ny) ';' num2str(Nb) ';' num2str(Alfa) ';' num2str(Alfax) ';' num2str(Alfay) ';' num2str(Int) ';' num2str(Intx) ';' num2str(Inty) ';' ...
            num2str(R2) ';' ...
            num2str(RmX) ';' num2str(RmY) ';' num2str(Rm) ';' ...
            num2str(VmX) ';' num2str(VmY) ';' num2str(Vm) ';' num2str(stdRx) ';' num2str(stdRy) ';' ...
            num2str(mean(Dux)) ';' num2str(mean(Duy)) ';' ...
            num2str(cvX) ';' num2str(cvY) ';' num2str(RxMax) ';' num2str(RyMax) ';' num2str(RMax) ';' num2str(RxMin) ';' num2str(RyMin) ';' num2str(RMin) ';'...
            num2str(VxMax) ';' num2str(VyMax) ';' num2str(VMax) ';' num2str(VxMin) ';' num2str(VyMin) ';' num2str(VMin) ';' num2str(log10(int12)) ';' num2str(cutTimex) ';' num2str(cutTimey)];
        fprintf(p,'%s\n',l); 
        disp(l);
        
    end
    fclose all;
   
end


function  [arq,tar]=extractName(fileName)
    %Identify the task in the file name
    po=find(fileName=='.',1,'last')-1;
    pi=find(fileName=='-',1,'first')-1;

    arq=fileName(1:pi);
    tar=fileName(pi+2:po);
end


function [Nx,Ny,Nb,Alfa,Alfax,Alfay,Int,Intx,Inty,RmX,RmY,Rm,VmX,VmY,Vm,stdRx,stdRy,Dux,Duy,Beta,R2,RxMax,RyMax,RMax,RxMin,RyMin,RMin,VxMax,VyMax,VMax,VxMin,VyMin,VMin,cutTimex,cutTimey]=Bullets(x,y,dx,dy,t,D_min,T_min,V_min,fs)

    [Nx,Rx,Vx,Dux,~,~,~,~,~,EnX,cutTimex]=findUM_Mean(t,x,dx,D_min,T_min,V_min,fs);
    [Ny,Ry,Vy,Duy,~,~,~,~,~,EnY,cutTimey]=findUM_Mean(t,y,dy,D_min,T_min,V_min,fs);
    scale=[abs(Rx);abs(Ry)];
    Vi=[Vx;Vy];
    E=[EnX;EnY];
    Const = polyfit(log(scale),log(Vi), 1);
    Constx = polyfit(log(abs(Rx)),log(Vx), 1);     %% Adicionei dia 20/05/2020 para achar o alfa e k de x e y separados
    Consty = polyfit(log(abs(Ry)),log(Vy), 1);     %% Idem
    [Rcor,~] = corr(log(scale),log(Vi));
    R2=Rcor^2;
    Alfa = Const(1);
    Alfax= Constx(1);
    Alfay= Consty(1);
    
    Int=exp(Const(2));
    Intx=exp(Constx(2));
    Inty=exp(Consty(2));
    
    Const = polyfit(log(scale),log(E), 1);
    Beta=Const(1);
    loglog(scale,E,'+');
    Nb=Nx+Ny;
    RmX=mean(abs(Rx));
    RmY=mean(abs(Ry));
    Rm=(RmX*Nx+RmY*Ny)/Nb;
    stdRx=std(abs(Rx));
    stdRy=std(abs(Ry));
    VmX=mean(abs(Vx));
    VmY=mean(abs(Vy));
    Vm=mean(abs(Vi));
    VxMax=max(abs(Vx));
    VyMax=max(abs(Vy));
    VxMin=min(abs(Vx));
    VyMin=min(abs(Vy));
    VMax=max([abs(VxMax),abs(VyMax)]);
    VMin=min([abs(VxMin),abs(VyMin)]);
    RxMax=max(abs(Rx));
    RyMax=max(abs(Ry));
    RxMin=min(abs(Rx));
    RyMin=min(abs(Ry));
    RMax=max([abs(RxMax),abs(RyMax)]);
    RMin=min([abs(RxMin),abs(RyMin)]);
end
