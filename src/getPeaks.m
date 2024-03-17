function Np=getPeaks(t,v,Ev)
v=(abs(v)>Ev).*v;
v=v-sign(v)*Ev;
[~,s]=findpeaks(v);
% hold off;
% plot(t,v);
% hold on;
% plot(t(s),v(s),'rv','MarkerFaceColor','g');
% hold off;
Np=length(s);
end