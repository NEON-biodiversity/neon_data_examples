source('R/get_neon_token.R')

library(neonDivData)
library(dplyr)
library(neonUtilities)

neonTaxonType="BIRD"
nddTaxonType="BIRDS"

neon_u_taxa <- neonUtilities::getTaxonTable(taxonType = neonTaxonType, token=get_neon_token())
ndd_taxa <- dplyr::filter(neon_taxa, taxon_group == nddTaxonType)

print(" compare row counts neonUtilities : neonDataDiv:")
print( paste(nrow(unique(neon_u_taxa)), ":", nrow(ndd_taxa)))

left_taxa <- dplyr::left_join(neon_u_taxa, ndd_taxa, by = c("taxonID" = "taxon_id") )
print('')
# filter out


print(paste("some genera only taxa", nddTaxonType))
genera_only_taxa <- dplyr::filter(ndd_taxa, taxon_rank == "genus") %>% dplyr::select(taxon_id, taxon_name)
print(head(genera_only_taxa))

