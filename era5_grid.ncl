;***********************************************
begin
	
	; lat_gl=fspan(-90,90,181)
	; lat_gl@units = "degree_north"
	; lon_gl=fspan(0,359,360)
	; lon_gl@units = "degree_east"
	
	; f_src1 = addfile(data_path1,"r")
	; lat_src1 = f_src1->latitude(::-1)
	; lon_src1 = f_src1->longitude
	; time_src1 = f_src1->time
	; data_src1 = short2flt(f_src1->v10(:,::-1,:))
	; data_new1= linint2(data_src1&longitude,data_src1&latitude, data_src1,True,lon_gl,lat_gl,0)
	; data_new1!0 = "time"
	; data_new1&time = time_src1
	; data_new1!1 = "lat"
	; data_new1&lat = lat_gl
	; data_new1!2 = "lon"
	; data_new1&lon = lon_gl
	; createNc3D(data_new1,"v10",data_new1&time,data_new1&lat,data_new1&lon)
	
	
	lat_gl=fspan(15,55,41)
	lat_gl@units = "degree_north"
	lon_gl=fspan(70,140,71)
	lon_gl@units = "degree_east"
	
	years = ispan(1959,2015,1)
	do i=0,dimsizes(years)-1
		year = tostring(years(i))
		f_src2 = addfile(data_path2+year+".nc","r")
		lat_src2 = f_src2->lat
		lon_src2 = f_src2->lon
		data_src2 = f_src2->pl
		data_new2= linint2(data_src2&lon,data_src2&lat, data_src2,True,lon_gl,lat_gl,0)
		data_new2!0 = "lat"
		data_new2&lat = lat_gl
		data_new2!1 = "lon"
		data_new2&lon = lon_gl
		createNc2D(data_new2,"pl",data_new2&lat,data_new2&lon)
		delete([/year,f_src2,lat_src2,lon_src2,data_new2/])
	end do
				
end
exit