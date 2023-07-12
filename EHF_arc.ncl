;***************************************************************************************************************
;-------------------------
undef("EHI_SIG")
function EHI_SIG(time,dataInput,data95)
;time: YY_DD
begin
	timeArr = str_split(time,"_")
	year = toint(timeArr(0))
	day = toint(timeArr(1))
	data = new((/3,64,128/),"float",999999.)
	if(year.eq.1)then
		if(day.lt.3)then
			data(0:2,:,:) = 999999.
		else
			f1 = addfile(dataInput + "year_" + tostring(year) + ".nc","r")
			data = f1->ts(day-3:day-1,:,:)
		end if
	else
		if(day.eq.1)then
			f1 = addfile(dataInput + "year_" + tostring(year-1) + ".nc","r")
			timetmp = f1->time
			data(0,:,:) = f1->ts(dimsizes(timetmp)-1,:,:)
			data(1,:,:) = f1->ts(dimsizes(timetmp)-2,:,:)
			f2 = addfile(dataInput + "year_" + tostring(year) + ".nc","r")
			data(2,:,:) = f2->ts(0,:,:)
		end if
		if(day.eq.2)then
			f1 = addfile(dataInput + "year_" + tostring(year-1) + ".nc","r")
			timetmp = f1->time
			data(0,:,:) = f1->ts(dimsizes(timetmp)-1,:,:)
			f2 = addfile(dataInput + "year_" + tostring(year) + ".nc","r")
			data(1,:,:) = f2->ts(0,:,:)
			data(2,:,:) = f2->ts(1,:,:)
		end if
		if(day.ge.3)then
			f1 = addfile(dataInput + "year_" + tostring(year) + ".nc","r")
			data = f1->ts(day-3:day-1,:,:)
		end if
	end if
	data := dim_avg_n_Wrap(data,0) - data95
	return data
end
;--------------------------------
;-------------------------
undef("EHI_ACCL")
function EHI_ACCL(time,dataInput)
;time:YY-DD
begin
	timeArr = str_split(time,"_")
	year = toint(timeArr(0))
	day = toint(timeArr(1))
	data1 = new((/3,64,128/),"float",999999.)
	if(year.eq.1)then
		if(day.lt.3)then
			data1(0:2,:,:) = 999999.
		else
			f1 = addfile(dataInput + "year_" + tostring(year) + ".nc","r")
			data1 = f1->ts(day-3:day-1,:,:)
		end if
	else
		if(day.eq.1)then
			f1 = addfile(dataInput + "year_" + tostring(year-1) + ".nc","r")
			timetmp = f1->time
			data1(0,:,:) = f1->ts(dimsizes(timetmp)-1,:,:)
			data1(1,:,:) = f1->ts(dimsizes(timetmp)-2,:,:)
			f2 = addfile(dataInput + "year_" + tostring(year) + ".nc","r")
			data1(2,:,:) = f2->ts(0,:,:)
		end if
		if(day.eq.2)then
			f1 = addfile(dataInput + "year_" + tostring(year-1) + ".nc","r")
			timetmp = f1->time
			data1(0,:,:) = f1->ts(dimsizes(timetmp)-1,:,:)
			f2 = addfile(dataInput + "year_" + tostring(year) + ".nc","r")
			data1(1,:,:) = f2->ts(0,:,:)
			data1(2,:,:) = f2->ts(1,:,:)
		end if
		if(day.ge.3)then
			f1 = addfile(dataInput + "year_" + tostring(year) + ".nc","r")
			data1 = f1->ts(day-3:day-1,:,:)
		end if
	end if
	data1 := dim_avg_n_Wrap(data1,0)
	
	data2 = new((/30,64,128/),"float",999999.)
	if(year.eq.1)then
		if(day.lt.33)then
			data2(0:29,:,:) = 999999.
		else
			f1 = addfile(dataInput + "year_" + tostring(year) + ".nc","r")
			data2 = f1->ts(day-33:day-4,:,:)
		end if
	else
		if(day.lt.4)then
			f1 = addfile(dataInput + "year_" + tostring(year-1) + ".nc","r")
			timetmp = f1->time
			data2(0:29,:,:) = f1->ts(dimsizes(timetmp)+day-33:dimsizes(timetmp)+day-4,:,:)
		else
			if(day.lt.33)then
				f1 = addfile(dataInput + "year_" + tostring(year-1) + ".nc","r")
				timetmp = f1->time
				data2(0:32-day,:,:) = f1->ts(dimsizes(timetmp)+day-33:dimsizes(timetmp)-1,:,:)
				f2 = addfile(dataInput + "year_" + tostring(year) + ".nc","r")
				data2(33-day:29,:,:) = f2->ts(0:day-4,:,:)
			else
				f1 = addfile(dataInput + "year_" + tostring(year) + ".nc","r")
				data2 = f1->ts(day-33:day-4,:,:)
			end if
		end if
	end if
	data2 := dim_avg_n_Wrap(data2,0)

	data = data1 - data2
	copy_VarMeta(data1,data)
	return data
end
;--------------------------------
;--------------------------------
undef("t95")
function t95(time,dataInput)
;time: DD
;dataInput: 
begin
	dataResult = new((/570,64,128/),"float")
	do i = 2,39
		if (toint(time).lt.8) then
			f1 = addfile(dataInput + "year_" + tostring(i-1) + ".nc","r")
			if (dimsizes(f1->time).eq.359)then
				data = f1->ts((351+toint(time)):358,:,:)
				f2 = addfile(dataInput + "year_" + tostring(i) + ".nc","r")
				data2 = f2->ts(0:(6+toint(time)),:,:)
				data := array_append_record(data,data2,0)
				dataResult((i-2)*15:((i-2)*15+14),:,:) = data
				delete([/data,f2,data2,data/])
			else
				data = f1->ts((352+toint(time)):359,:,:)
				f2 = addfile(dataInput + "year_" + tostring(i) + ".nc","r")
				data2 = f2->ts(0:(6+toint(time)),:,:)
				data := array_append_record(data,data2,0)
				dataResult((i-2)*15:((i-2)*15+14),:,:) = data
				delete([/data,f2,data2,data/])
			end if
			delete([/f1/])
		else
			if (toint(time).lt.354) then
				f1 = addfile(dataInput + "year_" + tostring(i) + ".nc","r")
				if(dimsizes(f1->time).eq.359)then
					if(toint(time).eq.353)
						data = f1->ts((toint(time)-9):(toint(time)+5),:,:)
					else
						data = f1->ts((toint(time)-8):(toint(time)+6),:,:)
					end if
					dataResult((i-2)*15:((i-2)*15+14),:,:) = data
				else
					data = f1->ts((toint(time)-8):(toint(time)+6),:,:)
					dataResult((i-2)*15:((i-2)*15+14),:,:) = data
				end if
				delete([/data,f1/])
			else
				f1 = addfile(dataInput + "year_" + tostring(i) + ".nc","r")
				if(dimsizes(f1->time).eq.359)then
					data = f1->ts((toint(time)-9):358,:,:)
					f2 = addfile(dataInput + "year_" + tostring(i+1) + ".nc","r")
					data2 = f2->ts(0:(toint(time)-354),:,:)
					data := array_append_record(data,data2,0)
					dataResult((i-2)*15:((i-2)*15+14),:,:) = data
					delete([/data,f2,data2/])
				else
					data = f1->ts((toint(time)-8):359,:,:)
					f2 = addfile(dataInput + "year_" + tostring(i+1) + ".nc","r")
					data2 = f2->ts(0:(toint(time)-354),:,:)
					data := array_append_record(data,data2,0)
					dataResult((i-2)*15:((i-2)*15+14),:,:) = data
					delete([/data,f2,data2/])
				end if
				delete([/f1/])
			end if
		end if
	end do
	index = dim_pqsort_n(dataResult,-2,0)
	dataResult := dataResult(28,:,:)
	return dataResult
end
;--------------------------------
begin
	dataInputAvgt 
    ; data_95_tmp = new((/360,64,128/),"float",999999)
	
    ; do i = 1,360
		; print(i)
		; DD = where(i.lt.10,"0"+tostring(i),tostring(i))
		; data_95_tmp(i-1,:,:) = t95(DD,dataInputAvgt)
    ; end do
    ; timeRange = ispan(1,360,1)
    ; data_95_tmp!0 = "time"
    ; data_95_tmp&time = timeRange
    ; createNc3D(data_95_tmp,"air95",data_95_tmp&time,data_95_tmp&lat,data_95_tmp&lon,"/export/home/XingW/Weijia/ipoamoenso/","air_95")
	; exit
    
	
	; f = addfile
	; data95_days = f->air95
	
	; data = new((/40,360,64,128/),"float",999999.)
	; do kk = 1,40
		; data_EHI_SIG = new((/360,64,128/),"float",999999.)
		; data_ACCL = new((/360,64,128/),"float",999999.)
		; if(mod(kk+2,4).eq.0)then
			; times = ispan(1,359,1)
			; do i = 0,dimsizes(times)-1
				; data_EHI_SIG(i,:,:) = EHI_SIG(tostring(kk) + "_" + tostring(times(i)),dataInputAvgt,data95_days(i,:,:))
				; data_ACCL(i,:,:) = EHI_ACCL(tostring(kk) + "_" + tostring(times(i)),dataInputAvgt)
			; end do
			; data_EHI_SIG(359,:,:) = 999999.
			; data_ACCL(359,:,:) = 999999.
		; else
			; times = ispan(1,360,1)
			; do i = 0,dimsizes(times)-1
				; data_EHI_SIG(i,:,:) = EHI_SIG(tostring(kk) + "_" + tostring(times(i)),dataInputAvgt,data95_days(i,:,:))
				; data_ACCL(i,:,:) = EHI_ACCL(tostring(kk) + "_" + tostring(times(i)),dataInputAvgt)
			; end do
		; end if
		; data_ACCL = where(data_ACCL.gt.1.0,data_ACCL,1.0)
		; data(kk-1,:,:,:) = data_EHI_SIG*data_ACCL
		; print(kk)
		; delete([/data_ACCL,data_EHI_SIG,times/])
	; end do
	; printVarSummary(data)
	; lats = f->lat
	; lons = f->lon
	; times = ispan(1,360,1)
	; years = ispan(1,40,1)
	; fout=addfile
    ; setfileoption(fout,"DefineMode",True)
        ; fAtt = True
            ; fAtt@title="JIA'S EHF"
            ; fAtt@creation_date=systemfunc("date")
        ; fileattdef(fout,fAtt)
        
        ; filedimdef(fout,(/"year","time","lat","lon"/),(/40,360,64,128/),(/False,False,False,False/))
        
        ; filevardef(fout,"year","integer","year")
        ; filevardef(fout,"time","integer","time")
        ; filevardef(fout,"lat","double","lat")
        ; filevardef(fout,"lon","double","lon")
        ; filevardef(fout,"EHF","float",(/"year","time","lat","lon"/))
        
        ; filevarattdef(fout,"year",years) 
        ; filevarattdef(fout,"time",times)  
        ; filevarattdef(fout,"lat" ,lats) 
        ; filevarattdef(fout,"lon" ,lons)
        ; filevarattdef(fout,"EHF",data)
        
    ; setfileoption(fout,"DefineMode",False)
    ; fout->year    = (/years/)        
    ; fout->time    = (/times/)    
    ; fout->lat    = (/lats/) 
    ; fout->lon    = (/lons/)
    ; fout->EHF  =  (/data/)
	
	dataInputAvgt 
	f = addfile(dataInputAvgt+"EHF.nc","r")
	data = f->EHF
	tmp = data
	data := where(data.ge.0,data,0)
	copy_VarMeta(tmp,data)
	data := dim_avg_n_Wrap(data(:,150:239,:,:),1)
	createNc3D(data,"EHF",data&year,data&lat,data&lon,)
	
	
end
exit
