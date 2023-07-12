
begin
	; dir_src 
	
	; time = ispan(1961,2017,1)
	
	; f_src = addfile(dir_src,"r")
	; data_src= f_src->hgt(:,{500},:,:)
	; lat = f_src->lat
	; lon = f_src->lon
	; printVarSummary(data_src)

	; data_noDtrend_result = new((/57,73,144/),"float")
	
	; do i = 1961,2017
		; data_noDtrend_result(i-1961,:,:) = dim_avg_n_Wrap(data_src((i-1961)*12+161:(i-1961)*12+163,:,:),0)
	; end do
	; data_result = dtrend_n(data_noDtrend_result,True,0)
	; data_result!0 = "time"
	; data_result!1 = "lat"
	; data_result!2 = "lon"
	; data_result&time = time
	; data_result&lat = lat
	; data_result&lon = lon
	; copy_VarMeta(data_result,data_noDtrend_result)
	
	; createNc3D(data_result,"hgt",data_result&time,data_result&lat,data_result&lon)
	; createNc3D(data_noDtrend_result,"hgt",data_noDtrend_result&time,data_noDtrend_result&lat,data_noDtrend_result&lon)
	
	
	f_nodtrend_src 
	f_nodtrend = addfile(f_nodtrend_src,"r")
	data_nodtrend = f_nodtrend->hgt
	
	data_avg = dim_avg_n_Wrap(data_nodtrend,0)
	data_avg_dims = conform_dims(dimsizes(data_nodtrend),data_avg,(/1,2/))
	
	data_nodtrend_jp = data_nodtrend - data_avg_dims
	
	data_dtrend_jp = dtrend_n(data_nodtrend_jp,True,0)
	copy_VarMeta(data_nodtrend,data_dtrend_jp)
	
	createNc3D(data_dtrend_jp,"hgt",data_dtrend_jp&time,data_dtrend_jp&lat,data_dtrend_jp&lon)
	
end
exit
