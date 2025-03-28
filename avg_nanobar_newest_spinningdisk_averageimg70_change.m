%find main folder name
mainfolder=pwd;
%find image averaing folders
ImgAvginfo=dir('*_image average');
nfolder=numel(ImgAvginfo);
load('position.mat');
load('maxfile.mat');
for n=1:nfolder
    
    cd(ImgAvginfo(n).name)

    %find avg images and format file
    Lipidfile=dir('*_w2TXR.tif');%如果有10个size，读的文件10在1前面
    GFPfile=dir('*_w3GFP.tif');
    Lipidimage=repmat(struct('diameter',[],'rawintensity',[],'bkgdsub',[],'rescale',[],'normalization',[],'mean_bkg',[]),10,1);
    GFPimage=repmat(struct('diameter',[],'rawintensity',[],'bkgdsub',[],'rescale',[],'normalization',[],'mean_bkg',[]),10,1);

    for i=1:numel(GFPfile)

    Lipidimage(i).diameter=100*(i);
    GFPimage(i).diameter=100*(i);
    Lipidimage(i).rawintensity=imread(Lipidfile(i).name);
    GFPimage(i).rawintensity=imread(GFPfile(i).name);

    end

    %Define and calculate bkgd


    %bkgd substraction and remove negative value
    for i=1:numel(GFPfile)

        %Define and calculate bkgd

        flat_lipid_bkg=mean(mean([Lipidimage(i).rawintensity(1:15,1:71) Lipidimage(i).rawintensity(57:71,1:71)]));
        flat_GFP_bkg=mean(mean([GFPimage(i).rawintensity(1:15,1:71) GFPimage(i).rawintensity(57:71,1:71)]));

        Lipidraw=Lipidimage(i).rawintensity;
        GFPraw=GFPimage(i).rawintensity;
        Lipidsub=Lipidraw-flat_lipid_bkg;
        GFPsub=GFPraw-flat_GFP_bkg;

        Lipidimage(i).bkgdsub=max(Lipidsub,0);
        GFPimage(i).bkgdsub=max(GFPsub,0);
        Lipidimage(i).mean_bkg=flat_lipid_bkg;
        GFPimage(i).mean_bkg=flat_GFP_bkg;
      
        

    end


    

    for i=1:numel(GFPfile)

        %find mean peak value at nanobar center

        txr_top_peak=position(1,numel(GFPfile)+1);
        txr_btm_peak=position(2,numel(GFPfile)+1);
        txr_left_peak=position(3,numel(GFPfile)+1);
        txr_right_peak=position(4,numel(GFPfile)+1);

        gfp_top_peak=position(5,numel(GFPfile)+1);
        gfp_btm_peak=position(6,numel(GFPfile)+1);
        gfp_left_peak=position(7,numel(GFPfile)+1);
        gfp_right_peak=position(8,numel(GFPfile)+1);

        center_lipid_peak=mean(mean([Lipidimage(numel(GFPfile)).bkgdsub(txr_top_peak,txr_left_peak:txr_right_peak) Lipidimage(numel(GFPfile)).bkgdsub(txr_btm_peak,txr_left_peak:txr_right_peak)]))/100;
        center_GFP_peak=mean(mean([GFPimage(numel(GFPfile)).bkgdsub(gfp_top_peak,gfp_left_peak:gfp_right_peak) GFPimage(numel(GFPfile)).bkgdsub(gfp_btm_peak,gfp_left_peak:gfp_right_peak)]))/100;

        Lipidnorm=Lipidimage(i).bkgdsub/center_lipid_peak;
        GFPnorm=GFPimage(i).bkgdsub/center_GFP_peak;
        
        Lipidimage(i).rescale=center_lipid_peak;
        GFPimage(i).rescale=center_GFP_peak;
        
        
        Lipidimage(i).normalization=Lipidnorm;
        GFPimage(i).normalization=GFPnorm;
        
        
    end


    data=repmat(struct('diameter',[],'Lipidsum',[],'Lipidend',[],'Lipidcenter',[],'GFPsum',[],'GFPend',[],'GFPcenter',[],'sumratio',[],'endratio',[],'centerratio',[],'lipid_etcratio',[],'GFP_etcratio',[],'etcratio',[],'lipid_wholesum',[],'GFP_wholesum',[],'wholeratio',[]),10,1);

    for i=1:numel(GFPfile)

        data(i).diameter=100*(i);
        r1=position(1,i);
        r2=position(2,i);
        c1=position(3,i);
        c2=position(4,i);
        c3=position(5,i);
        c4=position(6,i);
        r3=position(7,i);
        r4=position(8,i);

        %for kd absolute intensity measurement using bkgd sub
        sum_GFP_kd=sum(sum(GFPimage(i).bkgdsub(r1:r2,c1:c4)));
        center_GFP_kd=sum(sum(GFPimage(i).bkgdsub(r1:r2,c2+1:c3-1)));
        end_GFP_kd=sum_GFP_kd-center_GFP_kd;
        
        data(i).GFPkdsum=sum_GFP_kd;
        data(i).GFPkdend=end_GFP_kd;
        data(i).GFPkdcenter=center_GFP_kd;
        
        %for curvature preference measurement
        sum_lipid=sum(sum(Lipidimage(i).normalization(r1:r2,c1:c4)));
        center_lipid=sum(sum(Lipidimage(i).normalization(r1:r2,c2+1:c3-1)));
        end_lipid=sum_lipid-center_lipid;
        
        sum_GFP=sum(sum(GFPimage(i).normalization(r1:r2,c1:c4)));
        center_GFP=sum(sum(GFPimage(i).normalization(r1:r2,c2+1:c3-1)));
        end_GFP=sum_GFP-center_GFP;


        % calculate normalized background mean value in both channels
        flat_lipid_nor_bkg=mean(mean([Lipidimage(i).normalization(1:15,1:71) Lipidimage(i).normalization(57:71,1:71)]));
        flat_GFP_nor_bkg=mean(mean([GFPimage(i).normalization(1:15,1:71) GFPimage(i).normalization(57:71,1:71)]));

        % validate center height comparing to normalized background

        T_centerHeight = 0.05; % set intensity threshold to 5% higher than flat_lipid/GFP_nor_bkg

        % validate top center line first, r1 and r3

        % valid lipid channel
        r1_new_lipid=r1;
        r2_new_lipid=r2;
        r3_new_lipid=r3;
        r4_new_lipid=r4;
        r1_new_GFP=r1;
        r2_new_GFP=r2;
        r3_new_GFP=r3;
        r4_new_GFP=r4;
        
        for row=r1:r3

        Row_mean_lipid=mean(Lipidimage(i).normalization(row,c2+1:c3-1));

            if Row_mean_lipid<flat_lipid_nor_bkg*(1+T_centerHeight) 

                if row <=(r1+r3)/2
                    r1_new_lipid=row+1;
                end

                if row >= (r1+r3)/2
                    r3_new_lipid=row-1;
                break;
                end

            end

        end


        if r3_new_lipid<r1_new_lipid
           r3_new_lipid=r1_new_lipid;
        end

        % valid GFP channel
        for row=r1:r3

        Row_mean_GFP =mean(GFPimage(i).normalization(row,c2+1:c3-1));

            if Row_mean_GFP<flat_GFP_nor_bkg*(1+T_centerHeight) 

                if row <=(r1+r3)/2
                    r1_new_GFP=row+1;
                end

                if row >= (r1+r3)/2
                    r3_new_GFP=row-1;
                break;
                end

            end

        end


        if r3_new_GFP<r1_new_GFP
           r3_new_GFP=r1_new_GFP;
        end

        % repeatk for bottom center line, r2 and r4

        for row=r4:r2

        Row_mean_lipid =mean(Lipidimage(i).normalization(row,c2+1:c3-1));

            if Row_mean_lipid<flat_lipid_nor_bkg*(1+T_centerHeight) 

                if row <=(r2+r4)/2
                    r4_new_lipid=row+1;
                end

                if row >= (r2+r4)/2
                    r2_new_lipid=row-1;
                break;
                end

            end

        end


        if r4_new_lipid>r2_new_lipid
           r4_new_lipid=r2_new_lipid;
        end

        % valid GFP channel
        for row=r4:r2

        Row_mean_GFP =mean(GFPimage(i).normalization(row,c2+1:c3-1));

            if Row_mean_GFP<flat_GFP_nor_bkg*(1+T_centerHeight) 

                if row <=(r2+r4)/2
                    r4_new_GFP=row+1;
                end

                if row >= (r2+r4)/2
                    r2_new_GFP=row-1;
                break;
                end

            end

        end


        if r4_new_GFP>r2_new_GFP
           r4_new_GFP=r2_new_GFP;
        end

        temp_center_up_GFP=mean(mean(GFPimage(i).normalization(r1_new_GFP:r3_new_GFP,c2+1:c3-1)));
        temp_center_btm_GFP=mean(mean(GFPimage(i).normalization(r4_new_GFP:r2_new_GFP,c2+1:c3-1)));
        temp_center_up_lipid=mean(mean(Lipidimage(i).normalization(r1_new_lipid:r3_new_lipid,c2+1:c3-1)));
        temp_center_btm_lipid=mean(mean(Lipidimage(i).normalization(r4_new_lipid:r2_new_lipid,c2+1:c3-1)));

        if temp_center_up_GFP > flat_GFP_nor_bkg*(1+T_centerHeight) && temp_center_btm_GFP > flat_GFP_nor_bkg*(1+T_centerHeight)
           center_GFP_area=[GFPimage(i).normalization(r1_new_GFP:r3_new_GFP,c2+1:c3-1);GFPimage(i).normalization(r4_new_GFP:r2_new_GFP,c2+1:c3-1)];
        end

        if temp_center_up_GFP > flat_GFP_nor_bkg*(1+T_centerHeight) && temp_center_btm_GFP < flat_GFP_nor_bkg*(1+T_centerHeight)
           center_GFP_area=GFPimage(i).normalization(r1_new_GFP:r3_new_GFP,c2+1:c3-1);
        end

        if temp_center_up_GFP < flat_GFP_nor_bkg*(1+T_centerHeight) && temp_center_btm_GFP > flat_GFP_nor_bkg*(1+T_centerHeight)
           center_GFP_area=GFPimage(i).normalization(r4_new_GFP:r2_new_GFP,c2+1:c3-1); 
        end

        if temp_center_up_GFP <= flat_GFP_nor_bkg*(1+T_centerHeight) && temp_center_btm_GFP <= flat_GFP_nor_bkg*(1+T_centerHeight)
           center_GFP_area=[GFPimage(i).normalization(r1_new_GFP:r3_new_GFP,c2+1:c3-1);GFPimage(i).normalization(r4_new_GFP:r2_new_GFP,c2+1:c3-1)];
        end

        if temp_center_up_lipid > flat_lipid_nor_bkg*(1+T_centerHeight) && temp_center_btm_lipid > flat_lipid_nor_bkg*(1+T_centerHeight)
           center_lipid_area=[Lipidimage(i).normalization(r1_new_lipid:r3_new_lipid,c2+1:c3-1);Lipidimage(i).normalization(r4_new_lipid:r2_new_lipid,c2+1:c3-1)];
        end

        if temp_center_up_lipid > flat_lipid_nor_bkg*(1+T_centerHeight) && temp_center_btm_lipid < flat_lipid_nor_bkg*(1+T_centerHeight)
           center_lipid_area=Lipidimage(i).normalization(r1_new_lipid:r3_new_lipid,c2+1:c3-1);
        end

        if temp_center_up_lipid < flat_lipid_nor_bkg*(1+T_centerHeight) && temp_center_btm_lipid > flat_lipid_nor_bkg*(1+T_centerHeight)
           center_lipid_area=Lipidimage(i).normalization(r4_new_lipid:r2_new_lipid,c2+1:c3-1); 
        end

        if temp_center_up_lipid < flat_lipid_nor_bkg*(1+T_centerHeight) && temp_center_btm_lipid < flat_lipid_nor_bkg*(1+T_centerHeight)
           center_lipid_area=[Lipidimage(i).normalization(r1_new_lipid:r3_new_lipid,c2+1:c3-1);Lipidimage(i).normalization(r4_new_lipid:r2_new_lipid,c2+1:c3-1)];
        end

        %end and center area sorting
        
        end_GFP_area1=GFPimage(i).normalization(r1:r2,c1:c2);
        end_GFP_area2=GFPimage(i).normalization(r1:r2,c3:c4);
        Send_GFP_area1=sort(end_GFP_area1(:),'descend');
        Send_GFP_area2=sort(end_GFP_area2(:),'descend');
        
        end_lipid_area1=Lipidimage(i).normalization(r1:r2,c1:c2);
        end_lipid_area2=Lipidimage(i).normalization(r1:r2,c3:c4);
        Send_lipid_area1=sort(end_lipid_area1(:),'descend');
        Send_lipid_area2=sort(end_lipid_area2(:),'descend');
        
        Scenter_GFP=sort(center_GFP_area(:),'descend');
        Scenter_lipid=sort(center_lipid_area(:),'descend');
        
        %load('maxfile.mat');
        
        max_end=maxfile(i,1);
        max_center=maxfile(i,2);
        
        end_GFP_sub=(mean(Send_GFP_area1(1:max_end))+mean(Send_GFP_area2(1:max_end)))/2;
        end_lipid_sub=(mean(Send_lipid_area1(1:max_end))+mean(Send_lipid_area2(1:max_end)))/2;
        center_GFP_sub=mean(Scenter_GFP(1:max_center));
        center_lipid_sub=mean(Scenter_lipid(1:max_center));
        
        whole_lipid=sum(sum(Lipidimage(i).normalization));
        whole_GFP=sum(sum(GFPimage(i).normalization));
        ratio_whole=whole_GFP/whole_lipid;

        ratio_sum=sum_GFP/sum_lipid;
        ratio_center=center_GFP/center_lipid;
        ratio_end=end_GFP/end_lipid;

        GFP_ratio=end_GFP_sub/center_GFP_sub;
        lipid_ratio=end_lipid_sub/center_lipid_sub;

        etcratio=GFP_ratio/lipid_ratio;

        data(i).Lipidsum=sum_lipid;
        data(i).GFPsum=sum_GFP;
        data(i).Lipidcenter=center_lipid;
        data(i).GFPcenter=center_GFP;
        data(i).Lipidend=end_lipid;
        data(i).GFPend=end_GFP;
        data(i).sumratio=ratio_sum;
        data(i).centerratio=ratio_center;
        data(i).endratio=ratio_end;
        data(i).GFP_etcratio=GFP_ratio;
        data(i).lipid_etcratio=lipid_ratio;
        data(i).lipid_wholesum=whole_lipid;
        data(i).GFP_wholesum=whole_GFP;
        data(i).wholeratio=ratio_whole;
        data(i).etcratio=etcratio;
        data(i).GFPmaxend=end_GFP_sub;
        data(i).lipidmaxend=end_lipid_sub;
        data(i).GFPmaxcen=center_GFP_sub;
        data(i).lipidmaxcen=center_lipid_sub;
        data(i).lipidcenterarea=Scenter_lipid;
      


    end

    save('Lipidimage', 'Lipidimage');
    save('GFPimage','GFPimage');
    save('data','data');
    cd(mainfolder);
end

cd(ImgAvginfo(1).name);

TotalData.Lipid.wholebar=[data.diameter];
TotalData.Lipid.barend=[data.diameter];
TotalData.Lipid.barcenter=[data.diameter];
TotalData.Lipid.wholeimg=[data.diameter];
TotalData.Lipid.etcratio=[data.diameter];
TotalData.GFP.wholebar=[data.diameter];
TotalData.GFP.barend=[data.diameter];
TotalData.GFP.barcenter=[data.diameter];
TotalData.GFP.wholeimg=[data.diameter];
TotalData.GFP.etcratio=[data.diameter];
TotalData.ratio.end=[data.diameter];
TotalData.ratio.center=[data.diameter];
TotalData.ratio.whole=[data.diameter];
TotalData.ratio.etc=[data.diameter];
TotalData.ratio.wholeimg=[data.diameter];
TotalData.samplesize=[data.diameter];
TotalData.kd.GFPwholebar=[data.diameter];
TotalData.kd.GFPend=[data.diameter];
TotalData.kd.GFPcenter=[data.diameter];

cd(mainfolder);

for n=1:nfolder
    
    cd(ImgAvginfo(n).name);
    load('data.mat');
    TotalData.Lipid.wholebar=[TotalData.Lipid.wholebar;data.Lipidsum];
    TotalData.Lipid.barend=[TotalData.Lipid.barend;data.Lipidend];
    TotalData.Lipid.barcenter=[TotalData.Lipid.barcenter;data.Lipidcenter];
    TotalData.Lipid.wholeimg=[TotalData.Lipid.wholeimg;data.lipid_wholesum];
    TotalData.Lipid.etcratio=[TotalData.Lipid.etcratio;data.lipid_etcratio];
    TotalData.GFP.wholebar=[TotalData.GFP.wholebar;data.GFPsum];
    TotalData.GFP.barend=[TotalData.GFP.barend;data.GFPend];
    TotalData.GFP.barcenter=[TotalData.GFP.barcenter;data.GFPcenter];
    TotalData.GFP.wholeimg=[TotalData.GFP.wholeimg;data.GFP_wholesum];
    TotalData.GFP.etcratio=[TotalData.GFP.etcratio;data.GFP_etcratio];
    TotalData.ratio.end=[TotalData.ratio.end;data.endratio];
    TotalData.ratio.center=[TotalData.ratio.center;data.centerratio];
    TotalData.ratio.whole=[TotalData.ratio.whole;data.sumratio];
    TotalData.ratio.etc=[TotalData.ratio.etc;data.etcratio];
    TotalData.ratio.wholeimg=[TotalData.ratio.wholeimg;data.wholeratio];
    TotalData.kd.GFPwholebar=[TotalData.kd.GFPwholebar;data.GFPkdsum];
    TotalData.kd.GFPend=[TotalData.kd.GFPend;data.GFPkdend];
    TotalData.kd.GFPcenter=[TotalData.kd.GFPcenter;data.GFPkdcenter];
    bar_count=dlmread('bar_count.txt');
    TotalData.samplesize=[TotalData.samplesize;bar_count(1:numel(GFPfile))];
    
    cd(mainfolder);
end

save('TotalData','TotalData');
save tempdata4.mat;    

clc;clear;









