;plot the change of surface temerature from 1979-2004 to 2069-2098
	ft	= addfile("~/WENGUI_LIANG/Monthly_CMIP6/Amon_CMIP6_TAS/TS_Ensemble/Asia/JJA/Ensemble.nc","r")

	to	= dim_avg_n_Wrap(ft->To(:,{10:90},{70:190}),0)
	tn	= dim_avg_n_Wrap(ft->Tn(:,{10:90},{70:190}),0)
	dt	= tn 
	dt	= tn - to
	printVarSummary(dt)

	fp	= addfile("/R2/wengui/WENGUI_LIANG/Monthly_CMIP6/PRE/Ensemble_PRE/JJA/Ensemble.nc","r")
	
	p	= fp->Ho

	Po	= dim_avg_n_Wrap(p(:,{10:90},{70:190}),0)
	Po	= Po*24*3600
	;printVarSummary(Po)

	fo	= addfile("../../20th/E-P/E-P_20th.nc","r")
	fn	= addfile("../../rcp85/E-P/E-P_rcp85.nc","r")
	
	epo	= fo->E_P(:,{10:90},{70:190})	
	epn	= fn->E_P(:,{10:90},{70:190})	
	lat	= fo->lat({10:90})
	lon	= fo->lon({70:190})
	printVarSummary(epo)
	
	delta	= epo
	delta	= epn - epo

	Mean	= dim_avg_n_Wrap(delta,0)
	dims	= dimsizes(Mean)
	
	Mean	= Mean*24.*3600./Po*100./dt
	Mean	= runave_n_Wrap(runave_n_Wrap(Mean,6,2,0),6,2,1)
	;wks	= gsn_open_wks("eps","detat")
	wks	= gsn_open_wks("png","JJA_PC_Trend_CMIP6_e-p")
	gsn_define_colormap(wks,"BlueWhiteOrangeRed")
	gsn_reverse_colormap(wks)	

	res	= True
	res@cnFillOn		= True
	res@cnLinesOn		= False
	res@gsnFrame		= False
	res@gsnDraw		= False
	res@gsnMaximize			= True

	res@mpMinLatF                   = 20      ; range to zoom in     on
        res@mpMaxLatF                   = 70
        res@mpMinLonF                   = 85
        res@mpMaxLonF                   = 170
        res@mpCenterLonF                = 100
        res@gsnAddCyclic                = False

	res@cnLevelSelectionMode        = "ManualLevels"     ; set manual contour levels
        res@cnMinLevelValF              = -8              ; set min contour level
        res@cnMaxLevelValF              = 8       ; set max contour level
        res@cnLevelSpacingF             = 1            ; set contour spacing

	res@gsnLeftString	= ""
	res@gsnRightString	= ""	
	res@pmLabelBarWidthF	= 0.7
	res@pmLabelBarHeightF	= 0.15
	res@lbBoxMinorExtentF 	= 0.2 ;-- decrease height of labelbar boxes and vp
	res@lbLabelFontColor 	= "black" ;-- label color
	res@lbLabelFontHeightF 	= 0.018 ;-- label font height
	res@pmLabelBarOrthogonalPosF	= 0.08

	res@tmXBLabelFontHeightF= 0.018
	res@tmYLLabelFontHeightF= 0.018
	
	plot	= gsn_csm_contour_map(wks,Mean,res)
	print(sum(Mean))

	;---plot the 7% line PRE---------------------------------;
	resc1				 = True
	resc1@gsnFrame		= False
	resc1@gsnDraw		= False
	resc1@gsnLeftString	= " "
	resc1@gsnRightString	= " "
	resc1@tiMainString	= " "
	
	resc1@cnLevelSelectionMode        = "ExplicitLevels"     ; set manual contour levels
        resc1@cnLevels     	         = (/7.5/)              ; set min contour level
        resc1@cnLineLabelsOn		 = True
	resc1@gsnAddCyclic                = False

	resc1@cnLineLabelInterval	 = 1
	resc1@cnLineLabelPlacementMode 	 = "constant"
	resc1@cnLineThicknessF		 = 10
	resc1@cnLineColor		 = "black"
	resc1@cnLineLabelFontColor	= "black"
	;resc1@cnLineColor		 = "green"
	;resc1@cnLineLabelFontColor	= "green"
	resc1@gsnContourNegLineDashPattern = 2
	resc1@cnLineDashSegLenF		= 0.1
	
	resc1@cnLineLabelFontHeightF	= 0.018
	resc1@cnInfoLabelOn	= False
	dp	= runave_n_Wrap(runave_n_Wrap(Mean,5,1,0),5,1,1)
	pcon	= gsn_csm_contour(wks,dp,resc1)

	overlay(plot,pcon)
	
	;--------------------------------------------;
	draw(plot)
	
	res1				= True
	res1@gsMarkerIndex		= 16
	res1@gsMarkerSizeF		= 0.0015	
	res1@gsMarkerColor		= "gray10"

	
	
	do i=0,dims(0)-1
		do j=0, dims(1)-1
			count	= 0
			MASK	= False
			do kk=0,17
				if (ismissing(Mean(i,j)) .eq. False .and. ismissing(delta(kk,i,j)) .eq. False) then
					if(Mean(i,j)*delta(kk,i,j) .gt. 0) then
						count = count + 1
					end if
				end if
				if(count .eq. 14) then
					;MASK	= True
                         	       gsn_polymarker(wks,plot,lon(j),lat(i),res1)
				end if
			end do
			;if (MASK .eq. False .and. ismissing(Mean(i,j)) .eq. False .and. ismissing(Raw(0,i,j)) .eq. False) then
                         ;       gsn_polymarker(wks,plot,lon(j),lat(i),res1)
                                   ;print("robust")
                        ;end if
		end do
	end do
	frame(wks)


	system("rm -f E-P_deta.nc")
	ff	= addfile("E-P_deta.nc","c")
	ff->E_P	= delta
