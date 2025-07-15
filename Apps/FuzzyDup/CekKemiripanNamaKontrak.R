KlusteringKemiripan <- function(Tahun, KDBA){
  Query <- glue::glue("
SELECT [PO_NOKONTRAK] as NomorKontrak
  	  ,max(coalesce(NM_SATKER,NM_BA)) as NamaSatker
      ,max(coalesce(PO_KETERANGAN,concat('Kontrak dengan ',VENDOR_NAME_ALT))) as NamaKontrak
      ,max([NILAI_KONTRAK]) as NilaiKontrak
      ,max([VENDOR_NAME_ALT]) as NamaVendor
      ,max([BULAN]) as BulanPengadaan
  FROM [Bidics].[dbo].[MasterKontrakSPAN]
  where TAHUN = '{Tahun}' and kd_ba = '{KDBA}' and NILAI_KONTRAK <= 200000000 and NILAI_KONTRAK > 0
  group by PO_NOKONTRAK
  order by BulanPengadaan
                    ")
  DataKontrak <- FetchData(Query)
  DataKontrak$Cleansing <- paste(trimws(DataKontrak$NamaKontrak), trimws(DataKontrak$NamaSatker))
  DataKontrak$Cleansing <- gsub("[^[:alnum:] ]",'',DataKontrak$Cleansing)
  NomorCluster <- 1
  hasil.akhir <- NULL
  Populasi <- length(DataKontrak$NamaKontrak)
  while(length(DataKontrak$NamaKontrak)>0){
    RujukanPembanding <- DataKontrak$Cleansing[1]
    JarakTeks <- stringdist(gsub(" ","",RujukanPembanding), 
                            gsub(" ","",DataKontrak$Cleansing),
                            method = "cosine")
    FilterJarak <- (JarakTeks <= 0.0125)
    NomorKontrak.temp <- DataKontrak$NomorKontrak[FilterJarak]
    NamaSatker.temp <- DataKontrak$NamaSatker[FilterJarak]
    NamaKontrak.temp <- DataKontrak$NamaKontrak[FilterJarak]
    NilaiKontrak.temp <- DataKontrak$NilaiKontrak[FilterJarak]
    NamaVendor.temp <- DataKontrak$NamaVendor[FilterJarak]
    BulanPengadaan.temp <- DataKontrak$BulanPengadaan[FilterJarak]
    SkorKemiripan.temp <- JarakTeks[FilterJarak]
    var.temp <- data.frame(KDBA = KDBA,
                           TAHUN = Tahun,
                           Cluster = NomorCluster,
                           NamaSatker = NamaSatker.temp,
                           NomorKontrak = NomorKontrak.temp,
                           NamaKontrak = NamaKontrak.temp,
                           NilaiKontrak = NilaiKontrak.temp,
                           NamaVendor = NamaVendor.temp,
                           Bulan = BulanPengadaan.temp,
                           Skor = SkorKemiripan.temp
    )
    nCluster <- nrow(var.temp)
    if(nCluster > 1){
      hasil.akhir <- rbind(hasil.akhir, var.temp)
      NomorCluster <- NomorCluster + 1
    }
    #Hapus yang sudah pernah dicek biar nggak dobel counting
    DataKontrak <- DataKontrak[!(FilterJarak),]
  }
  return(hasil.akhir)
}

# Looping by KDBA
con <- DBI::dbConnect(odbc::odbc(),
                      driver = "ODBC Driver 17 for SQL Server",
                      server = "HQBDHUB01.bpk.go.id",
                      database = "Bidics",
                      uid = "bidics",
                      pwd = "pusaka")
Query <- glue::glue("select KD_BA, NM_BA, TAHUN 
FROM [Bidics].[dbo].[MasterKontrakSPAN]
GROUP by KD_BA, NM_BA, TAHUN 
ORDER BY KD_BA, TAHUN")
DaftarBAbyTahun <- FetchData(Query)
ctr <- nrow(DaftarBAbyTahun)
for(i in 1:ctr){
  Data.temp <- KlusteringKemiripan(Tahun = DaftarBAbyTahun$TAHUN[i], KDBA = DaftarBAbyTahun$KD_BA[i])
  if(!is.null(Data.temp)){
    dbWriteTable(con, 'KemiripanNamaKontrak',Data.temp, overwrite = FALSE, append = TRUE )
    print(paste("Saved ",DaftarBAbyTahun$NM_BA[i], "Tahun:", DaftarBAbyTahun$TAHUN[i]))
  } else {
    print(paste("N/A ",DaftarBAbyTahun$NM_BA[i], "Tahun:", DaftarBAbyTahun$TAHUN[i]))
  }
}
