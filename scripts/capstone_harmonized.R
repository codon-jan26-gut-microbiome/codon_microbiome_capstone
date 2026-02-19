# Setting up and loading data ----
setwd("C:/previous desktop folders/Desktop/CAPSTONE PROJECT")
pacman::p_load(tidyverse, janitor, ggpubr, vegan, Maaslin2)
rm(list = ls())

load("Data/DIABIMMUNE_Karelia_metadata_sub.RData", verbose = TRUE)
#Q1 ----
##Q1A Doing some initial eda on meta data ----
dim(metadata_all)               # 1946 rows 18 col
view(metadata_all)
colnames(metadata_all)          # 18 colnames ....

##Q1B Filtering the samples by shotgun (non-NA gid_wgs, by age and first ever collected sample) ----
metadata_filt <- metadata_all %>% 
  filter(!is.na(gid_wgs), age_at_collection <= 365 ) %>%  
  group_by(subjectID) %>% 
  slice_min(age_at_collection , n = 1) %>%
  column_to_rownames("gid_wgs") # 162 individuals , first collected sample of each only 

dim(metadata_filt) # 162  17


##Q1C Identifying species level taxonomy profiles corresponding to the filtered samples ----
### Loading taxa data from CMData from Bioconductor Experiment Hub  -----
cdata <- curatedMetagenomicData::curatedMetagenomicData(
  "VatanenT_2016.relative_abundance",
  dryrun = FALSE , 
  counts = FALSE )              #Large list (7.3 MB)

cdata <- cdata[[1]]
taxa_data <- assay(cdata)
rm(cdata)

dim(taxa_data)                  # 618 rows 785 cols
taxa_data[1:5 , 1:5]            # rownames = taxanomy  , colnames = gid_wgs ID

### Checking for overlap between taxa_data & metadata_filt ----
ggvenn::ggvenn(
  list(
    metadata_filt = rownames(metadata_filt),
    taxa_data   = colnames(taxa_data)
  )
)
#--#--#---#--#--#--#--#--#--#--#--#--#
keep_ids <- intersect(colnames(taxa_data) , rownames(metadata_filt))
length(keep_ids)                # 785 samples ->  147 samples (gid_wgs) 

metadata_filt <- metadata_filt[keep_ids , ]
taxa_data <- taxa_data[ , keep_ids]
# if u want to check go and check the venn diagram 

### Changing the taxa name to species level
ranks <- c("Kingdom", "Phylum", "Class", "Order",
           "Family", "Genus", "Species", "Strain")

taxa_data_byspecies <- taxa_data %>%
  as.data.frame() %>%
  rownames_to_column("Org") %>%
  separate(
    Org,
    into = ranks,
    sep = "\\|",
    fill = "right",
    extra = "drop"
  ) %>%
  filter(!is.na(Species), is.na(Strain)) %>%
  select(Species, everything(), -Kingdom, -Phylum,
         -Class, -Order, -Family, -Genus, -Strain) %>%
  mutate(Species = make.unique(Species)) %>%
  column_to_rownames("Species") %>%
  as.matrix()

dim(taxa_data_byspecies)
dim(taxa_data)
rm(taxa_data)

### Checking if both taxa_data and metadata_filt are identical ----
identical(rownames(metadata_filt) , colnames(taxa_data_byspecies))    # TRUE 
rm(keep_ids)

## Q1D Part 1 ----
###Filter low abundance taxa (threshold = 0.01% ----

taxa_data_byspecies[ taxa_data_byspecies < 0.01 ] <- 0  #logical indexing # [] usede for subsetting 

## Q1D Part 2 ----
### How many species remain? (335)----

keep_species <- which( rowSums(taxa_data_byspecies) > 0 )
taxa_data_byspecies <- taxa_data_byspecies[ keep_species, ]    # all rows with net 0 removed 

dim(taxa_data_byspecies)                      # (335rows 147 cols) , 618 rows dropped to 335 (species)  
rm(keep_species) 

taxa_data <- taxa_data_byspecies              #long name shortened back because dont really need to specify after this qn 
rm(taxa_data_byspecies)

##Q1E ----
### Apply total sum scaling (TSS) normalization ----
col_totals <- colSums(taxa_data)
taxa_tss_data <- sweep(
  taxa_data[, col_totals > 0, drop = FALSE],
  2,
  col_totals[col_totals > 0],
  "/"
)

# Qn 2  ----

## Q2A Milk and egg allergies across countries ----

ggplot(metadata_filt , aes(x = country , fill = allergy_milk)) +
  geom_bar(position = "fill") +
  labs(x = NULL, y = NULL) + 
  scale_y_continuous(labels = scales::percent)

##better looking version of 2A. ----
library(tidyverse)
library(scales)

ggplot(metadata_filt %>% tibble::as_tibble(),
       aes(x = country, fill = factor(allergy_milk))) +
  geom_bar(position = position_dodge(width = 0.8), width = 0.7) +
  geom_text(
    stat = "count",
    aes(label = after_stat(count)),
    position = position_dodge(width = 0.8),
    vjust = -0.4,
    size = 4
  ) +
  scale_fill_brewer(palette = "Set1", name = "Milk allergy") +
  labs(x = "Country", y = "Number of children") +
  theme_minimal(base_size = 14) +
  theme(axis.text.x = element_text(angle = 20, hjust = 1))


##Q2B Covariates across countries  ----

metadata_covariates <- metadata_filt %>% 
  select(country , delivery , Exclusive_breast_feeding , age_at_collection)

#age distribution 
ggplot(metadata_covariates, aes(x = country, y = age_at_collection, fill = country)) +
  geom_boxplot(outlier.shape = NA) +
  geom_jitter(width = 0.15, alpha = 0.35, size = 1) +
  labs(x = "country", y = "age at collection (days)") +
  theme(legend.position = "none")

#delivery distribution 
ggplot(metadata_covariates , aes(x = country  , fill = delivery)) + 
  geom_bar( ) + labs( x = "country" , y = " type of delivery ")
##better version for delivery distribution ----
library(tidyverse)

ggplot(metadata_covariates %>% tibble::as_tibble(),
       aes(x = country, fill = delivery)) +
  geom_bar(position = position_dodge(width = 0.8),
           width = 0.7, color = "white", linewidth = 0.3) +
  geom_text(
    stat = "count",
    aes(label = after_stat(count)),
    position = position_dodge(width = 0.8),
    vjust = -0.35,
    size = 4
  ) +
  scale_fill_brewer(palette = "Dark2", name = "Delivery") +
  labs(title = "Delivery mode by country",
       x = "Country", y = "Number of children") +
  theme_minimal(base_size = 14) +
  theme(
    axis.text.x = element_text(angle = 20, hjust = 1),
    panel.grid.major.x = element_blank(),
    panel.grid.minor = element_blank(),
    plot.title = element_text(face = "bold")
  )


#breast feeding distribution 
ggplot(metadata_covariates , aes(x = country  , fill = Exclusive_breast_feeding)) + 
  geom_bar( ) + labs( x = "country" , y = "Breastfed children") # this is the simpler version of the chart 

##better version for breast feeding distribution ----
library(tidyverse)
df_bf <- metadata_covariates %>%
  tibble::as_tibble() %>%
  mutate(Exclusive_breast_feeding = as.logical(Exclusive_breast_feeding)) %>%
  dplyr::count(country, Exclusive_breast_feeding, name = "n")

df_bf

ggplot(df_bf, aes(x = country, y = n, color = Exclusive_breast_feeding)) +
  geom_linerange(aes(ymin = 0, ymax = n),
                 position = position_dodge(width = 0.5),
                 linewidth = 1) +
  geom_point(position = position_dodge(width = 0.5), size = 3) +
  geom_text(aes(label = n),
            position = position_dodge(width = 0.5),
            vjust = -0.6, size = 4) +
  labs(x = "Country", y = "Number of children", color = "Exclusive breastfeeding") +
  theme_minimal(base_size = 14)




