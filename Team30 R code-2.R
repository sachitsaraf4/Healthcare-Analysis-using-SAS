library("utils")
library("tidyverse")
library(ggplot2)

health <- read_csv("raw data.csv")
health = subset(health, select = -c(case_id, Hospital_code,patientid,City_Code_Patient))
View(health)

health <- health %>% filter_all(all_vars(!is.na(.)))
health[is.na(health),]
health = health[sample(nrow(health), trunc(nrow(health) * 0.5)), ]
colnames(health) <- c("hospital_type_code", "city_code_hospital", "hospital_region_code", 
                      "available_extra_rooms", "department", "ward_type", 
                      "ward_facility_code", "bed_grade", "type_of_admission", 
                      "severity_of_illness", "visitors_with_patient", "age", "admission_deposit", "stay")
write.csv(health,"/Users/apple/Desktop/health.csv",row.names = FALSE)


#data visualization
geo<- ggplot(health, aes(hospital_region_code,hospital_type_code))+
  geom_tile(aes(fill=stay))
geo

hos<- ggplot(health, aes(ward_type,available_extra_rooms))+
  geom_tile(aes(fill=stay))
hos

patient<- ggplot(health, aes(age,visitors_with_patient))+
  geom_tile(aes(fill=stay))
patient

