function [X,y]= data_extract() 
    [X1,cdwtr]=read_script();
    disp('read temp., pres, cldwtr');
    disp(clock);
   % X1=double(X1);
    X2=read_shumUV();
    disp('read shum, u, v');
    X=[X1 X2];
    cdwtr=cdwtr(:,:);
    A1=[]; ydata=[];c=0;
    data=X(:,:);
    for i=1:142,
           A1=[A1;data(c+150:c+272, [29:210 239:420 449:630 659:840 869:1050 1079:1260 1289:1470 1499:1680 ] )];
%            ydata=[ydata;cdwtr(c+150:c+272, [72:83 87:97 101:111 129:138 143:153 157:165 171:179 186:193 200:205] )];
           ydata=[ydata;cdwtr(c+150:c+272, [69 83 97 111 112 130 158 159 172 173] )];
        
        if mod((i-2),4)==0,
            c=c+366;
        else
           c=c+365;
        end;
    end;

    X=A1;
    rdata = [ydata(2:end,:);ydata(end,:)];
    y=rdata;
    save('input_noCov.mat','X');
    save('output_south.mat','y');
%  [X1,cdwtr]=read_script();
%     disp('read temp., pres, cldwtr');
%     disp(clock);
%     X1=double(X1);
%     X2=read_shumUV();
%     disp('read shum, u, v');
%     X=[X1 X2 cdwtr];
%     X=X(29220:48943,:);
%     rain=data_read();
% %     rain=rain(:,[33 64 74 83 109 174]);
%     %cdwtr=cdwtr(:,[33 64 74 83 109 174]);
% %     A1=[]; ydata=[];c=0;
% %     data=X(:,:);
% %     for i=1:54,
% %            A1=[A1;data(c+150:c+272,:)];
% %            ydata=[ydata;rain(c+150:c+272,:)];
% %         if mod((i-2),4)==0,
% %             c=c+366;
% %         else
% %            c=c+365;
% %         end;
% %     end;

%     %X=A1;
%     rdata = [rain(2:end,:);rain(end,:)];
%     %rdata = [ydata(2:end,:);ydata(end,:)];
%     y=rdata;
%     
end