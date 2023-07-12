;***************************************************************************************************************
undef("getNcepData")
function getNcepData(startTime,endTime,dataInputPath,var)

; 	startTime      
; 	endTime        
; 	dataInputPath   
; 	var            
begin
	
	startTime := str_sub_str(startTime,"-","")
	endTime := str_sub_str(endTime,"-","")
	index = ind(modelNames.eq.modelName)
	day = days(index)
	if(day.eq.28)
		YMDList = get28YMD(startTime,endTime)
	else
		YMDList = getrealYMD(startTime,endTime)
	end if
	startYear = substr(YMDList(0),0,3)
	endYear = substr(YMDList(dimsizes(YMDList)-1),0,3)
	do i = toint(startYear),toint(endYear)
		if(startYear.eq.endYear)
			startTime_year = YMDList(0)
			endTime_year = YMDList(dimsizes(YMDList)-1)
			f = addfile(dataPath+startYear+".nc","r")
			time = f->time
			time := cd_calendar(time,2)
			startIndex = ind(time.eq.startTime_year)
			endIndex = ind(time.eq.endTime_year)
			data = f->$var$(startIndex:endIndex,:,:)
		else
		if(i.eq.toint(startYear))
			startTime_year = YMDList(0)
			endTime_year = startYear + "1231"
			f = addfile(dataPath+startYear+".nc","r")
			time = f->time
			time := cd_calendar(time,2)
			startIndex = ind(time.eq.startTime_year)
			endIndex = ind(time.eq.endTime_year)
			data = f->$var$(startIndex:endIndex,:,:)
			; printVarSummary(data)
		else
			if(i.eq.toint(endYear))
				startTime_year = endYear+"0101"
				endTime_year = YMDList(dimsizes(YMDList)-1)
				f = addfile(dataPath+endYear+".nc","r")
				time = f->time
				time := cd_calendar(time,2)
				startIndex = ind(time.eq.startTime_year)
				endIndex = ind(time.eq.endTime_year)
				temp = f->$var$(startIndex:endIndex,:,:)
				; printVarSummary(temp)
			else
				f = addfile(dataPath+tostring(i)+".nc","r")
				temp = f->$var$
				time = f->time
				startIndex = 0
				endIndex = 0
				startTime_year = "0"
				endTime_year = "0"
			end if
		end if
		end if
		if(i.eq.toint(startYear))
			
		else
			data := array_append_record(data,temp,0)
			delete(temp)
		end if
		delete([/f,time,startIndex,endIndex,startTime_year,endTime_year/])
	end do
	return data
end
;***************************************************************************************************************
undef("forwardDaysNew")
function forwardDaysNew(time:string,prexdays:integer,modelName)
begin
	modelNames = (/"ACCESS-CM2","CanESM5","CMCC-CM2-SR5","EC-Earth3","FGOALS-g3","IPSL-CM6A-LR","MIROC6","MPI-ESM1-2-HR","MPI-ESM1-2-LR","MRI-ESM2-0","NorESM2-LM","NorESM2-MM"/)
	daysAll = (/29,28,28,29,28,29,29,29,29,29,28,28/)
	index = ind(modelNames.eq.modelName)
	day = daysAll(index)
	if(day.eq.29)
		timeArr = tointeger(str_split(time,"-"))
		year = timeArr(0)
		days = day_of_year(timeArr(0),timeArr(1),timeArr(2)) + prexdays
		yd = where(isleapyear(year),366,365)
		if(days.gt.yd)then
			year = year+1
			days = days - yd
		end if
		if(days.le.0)then
			year = year-1
			days = days+ where(isleapyear(year),366,365)
		end if
		ydStr = year+""+where(days.lt.10,"00",where(days.lt.100,"0",""))+days
		ymd = tostring(yyyyddd_to_yyyymmdd(tointeger(ydStr)))
		resultTime = substr(ymd,0,3)+"-"+substr(ymd,4,5)+"-"+substr(ymd,6,7)
	else
		timeArr = tointeger(str_split(time,"-"))
		year = timeArr(0)
		days = day_of_year(2019,timeArr(1),timeArr(2)) + prexdays
		yd = 365
		if(days.gt.yd)then
			year = year+1
			days = days - yd
		end if
		if(days.le.0)then
			year = year-1
			days = days+ 365
		end if
		ydStr = year+""+where(days.lt.10,"00",where(days.lt.100,"0",""))+days
		ymd = tostring(yyyyddd_to_yyyymmdd(tointeger(ydStr)))
		resultTime = substr(ymd,0,3)+"-"+substr(ymd,4,5)+"-"+substr(ymd,6,7)
	end if
	return resultTime
end

;----------------------------------------------------------
undef("getTimeList")
function getTimeList(startRange:integer,endRange:integer)
begin	
	ti = yyyymmdd_time(startRange/10000,endRange/10000,"integer")
	T = ti({startRange:endRange})
	return T
end
;-------------------------
undef("EHI_SIG")
function EHI_SIG(time,data95,modelName,ssp,var)
;time:YYYY-MM-DD
begin
	lat = data95&lat
	lon = data95&lon
	data = new((/3,dimsizes(lat),dimsizes(lon)/),"float")
	startTime = forwardDaysNew(time,-2,modelName)
	data = getModeDatas(startTime,time,modelName,ssp,var)
	data := dim_avg_n_Wrap(data,0) - data95
	return data
end
;--------------------------------
;-------------------------
undef("EHI_ACCL")
function EHI_ACCL(time,data95,modelName,ssp,var)
;time:YYYY-MM-DD
begin
	lat = data95&lat
	lon = data95&lon
	data1 = new((/3,dimsizes(lat),dimsizes(lon)/),"float")
	startTime1 = forwardDaysNew(time,-2,modelName)
	data1 = getModeDatas(startTime1,time,modelName,ssp,var)
	data1 := dim_avg_n_Wrap(data1,0)
	
	data2 = new((/30,dimsizes(lat),dimsizes(lon)/),"float")
	startTime = forwardDaysNew(time,-32,modelName)
	endTime = forwardDaysNew(time,-3,modelName)
	data2 = getModeDatas(startTime,endTime,modelName,ssp,var)
	data2 := dim_avg_n_Wrap(data2,0)
	data = data1 - data2
	copy_VarMeta(data1,data)
	return data
end
;--------------------------------
undef("t95")
function t95(time,modelName,ssp,var)
;time:MM-DD
begin
	dataPath 
	f = addfile(dataPath,"r")
	lat = f->lat
	lon = f->lon
	data = new((/855,dimsizes(lat),dimsizes(lon)/),"float")
	do i = 1961,2017
		startIndex = (i-1961)*15
		endIndex = (i-1961)*15 + 14
		times = tostring(i) + "-" + time
		startTime = forwardDaysNew(times,-7,modelName)
		endTime = forwardDaysNew(times,7,modelName)
		data(startIndex:endIndex,:,:) = getModeDatas(startTime,endTime,modelName,ssp,var)	
	end do
	index = dim_pqsort_n(data,-2,0)
	data := data(42,:,:)
	return data
end
;--------------------------------
begin
	
	modelName = "ACCESS-CM2"
	ssp = "historical"
	var = "tmp"
	
	
    ; data_95_tmp = new((/153,73,144/),"float")
    ; startTime = "20200501"
	; endTime = "20200930"
	; YMD = getTimeList(toint(startTime),toint(endTime))
    ; do i = 0,152
       ; MMDD = substr(YMD(i),4,5)+"-"+substr(YMD(i),6,7)
       ; data_95_tmp(i,:,:) = t95(MMDD,dataInputAvgt)
    ; end do
    ; timeRange = ispan(1,153,1)
    ; data_95_tmp!0 = "time"
    ; data_95_tmp&time = timeRange
    ; createNc3D(data_95_tmp,"air95",data_95_tmp&time,data_95_tmp&lat,data_95_tmp&lon)
    ; exit
	f = addfile
	data95_days = f->air95
	data = new((/60,153,73,144/),"float")
	do kk = 1961,2020
		data_EHI_SIG = new((/153,73,144/),"float")
		data_ACCL = new((/153,73,144/),"float")
		startTime = "05-01"
		endTime = "09-30"
		startTimeInt = str_sub_str(tostring(kk) + "-" + startTime,"-","")
		endTimeInt = str_sub_str(tostring(kk) + "-" + endTime,"-","")
		YMD = getTimeList(toint(startTimeInt),toint(endTimeInt))
		do i = 0,dimsizes(YMD)-1
			data_EHI_SIG(i,:,:) = EHI_SIG(tostring(kk) + "-" + substr(YMD(i),4,5) + "-" + substr(YMD(i),6,7),dataInputAvgt,data95_days(i,:,:))
			data_ACCL(i,:,:) = EHI_ACCL(tostring(kk) + "-" + substr(YMD(i),4,5) + "-" + substr(YMD(i),6,7),dataInputAvgt)
		end do
		data_ACCL = where(data_ACCL.gt.1.0,data_ACCL,1.0)
		data(kk-1961,:,:,:) = data_EHI_SIG*data_ACCL
		print(kk)
		delete([/data_ACCL,data_EHI_SIG,startTime,endTime,startTimeInt,endTimeInt,YMD/])
	end do
	;-------------------------------------------------------------------------;
	year = ispan(1961,2020,1)
	time = ispan(1,153,1)
	lat = fspan(-90,90,73)
	lat@units = "degree_north"
	lon = fspan(0,357.5,144)
	lon@units = "degree_east"
	;-------------------------------------------------------;
	fout=addfile
    setfileoption(fout,"DefineMode",True)
        fAtt = True
            fAtt@title="JIA'S EHF"
            fAtt@creation_date=systemfunc("date")
        fileattdef(fout,fAtt)
        
        filedimdef(fout,(/"year","time","lat","lon"/),(/60,153,73,144/),(/False,False,False,False/))
        
        filevardef(fout,"year","integer","year")
        filevardef(fout,"time","integer","time")
        filevardef(fout,"lat","float","lat")
        filevardef(fout,"lon","float","lon")
        filevardef(fout,"EHF","float",(/"year","time","lat","lon"/))
        
        filevarattdef(fout,"year",year) 
        filevarattdef(fout,"time",time)  
        filevarattdef(fout,"lat" ,lat) 
        filevarattdef(fout,"lon" ,lon)
        filevarattdef(fout,"EHF",data)
        
    setfileoption(fout,"DefineMode",False)
    fout->year    = (/year/)        
    fout->time    = (/time/)    
    fout->lat    = (/lat/) 
    fout->lon    = (/lon/)
    fout->EHF  =  (/data/)
	;------------------------------------------------------------------------;
end
exit
