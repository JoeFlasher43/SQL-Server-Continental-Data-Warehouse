SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*	Setup test tables with correct indices.
select *
into dbo.fdr_mf_base_jcf
from Warehouse.dbo.fdr_mf_base_20201101 with (nolock)

select *
into dbo.fdr_mf_cust_jcf
from Warehouse.dbo.fdr_mf_cust_20201101 with (nolock)

select *
into dbo.fdr_mf_curr_jcf
from Warehouse.dbo.fdr_mf_curr_20201101 with (nolock)

select *
into dbo.fdr_mf_hist_jcf
from Warehouse.dbo.fdr_mf_hist_20201101 with (nolock)

select *
into dbo.fdr_mf_beha_jcf
from Warehouse.dbo.fdr_mf_beha_20201101 with (nolock)

select *
into dbo.fdr_mf_delq_jcf
from Warehouse.dbo.fdr_mf_delq_20201101 with (nolock)

create unique clustered index uclx on dbo.fdr_mf_base_jcf (IFO_BASE_FULL_ACCT_NO);
create unique clustered index uclx on dbo.fdr_mf_cust_jcf (IFO_CUST_FULL_ACCT_NO);
create unique clustered index uclx on dbo.fdr_mf_curr_jcf (IFO_CURR_FULL_ACCT_NO);
create unique clustered index uclx on dbo.fdr_mf_hist_jcf (IFO_HIST_FULL_ACCT_NO);
create unique clustered index uclx on dbo.fdr_mf_beha_jcf (IFO_BEHA_FULL_ACCT_NO);
create unique clustered index uclx on dbo.fdr_mf_delq_jcf (IFO_DELQ_FULL_ACCT_NO);

drop index dbo.fdr_mf_base_jcf.nclx_IFO_USER_TX_IFO_ACCT_CT
create nonclustered index nclx_IFO_USER_TX_IFO_ACCT_CT on dbo.fdr_mf_base_jcf (IFO_USER_TX, IFO_ACCT_CT desc);

--Name Function
select top 100
	IFO_PRINCIPAL_NAME,
	LastName = substring(IFO_PRINCIPAL_NAME,1,CHARINDEX(',',IFO_PRINCIPAL_NAME,1)-1)
	FirstName =	case
					when CHARINDEX(',',IFO_PRINCIPAL_NAME,1) = 0
					then null
					when CHARINDEX(' ',IFO_PRINCIPAL_NAME,1) > 0
					then substring(IFO_PRINCIPAL_NAME,CHARINDEX(',',IFO_PRINCIPAL_NAME,1)+1,CHARINDEX(' ',IFO_PRINCIPAL_NAME,1) -  CHARINDEX(',',IFO_PRINCIPAL_NAME,1))
					else null
				end
from dbo.fdr_mf_cust_jcf

*/
-- ========================================================
-- Author:		Joe Flasher - White Dog SQL Consulting, LLC
-- Create date: 3/2/2021
-- Description:	Load the FDRMasterFact.
-- For:			Continental Finance Company, LLC
-- ========================================================
--CREATE OR ALTER PROCEDURE dbo.LoadFDRMasterFactTable
--AS
--BEGIN
	SET NOCOUNT ON;

	--if object_id('dbo.FDRMasterFact','U') is null
	--	create table dbo.FDRMasterFact
	--	(	IFO_BASE_FULL_ACCT_NO		varchar(28),
	--		SystemId						varchar(4),
	--		PRIN						varchar(4),
	--		Agent						varchar(4),
	--		AcctNo						varchar(16),
	--		AcctNoLast4					varchar(4),
	--		IFO_ACCT_CT					int,
	--		IFO_USER_TX					varchar(24),
	--		IFO_CROSS_REFERENCE_ACCT_NO	varchar(16),
	--		IFO_NEW_XREF_NO_1			varchar(16),
	--		IFO_NEW_XREF_NO_2			varchar(16),
	--		IFO_MULTRAN_FLAG			varchar(1),
	--		IFO_CUST_XREF_ID			varchar(16),
	--		AcctTransferJulianDate		varchar(5),
	--		AcctTransferFlag		varchar(1),
	--		PortfolioNo			varchar(4)
	--	);

	drop table if exists #Dedupe;
	drop table if exists #Base;
	drop table if exists #Cust;
	drop table if exists #Pass1;
	drop table if exists #Pass2;
	drop table if exists #Pass3;
	go

	create table #Dedupe
	(	AcctKey								bigint,
		IFO_USER_TX							varchar(24),
		IFO_ACCT_CT							int,
		Dedupe								bigint
	);

	create unique clustered index uclx on #Dedupe (AcctKey);

	create table #Base
	(	AcctKey								bigint,
		FullAcctNo							varchar(28),
		SystemId							varchar(4),
		PRIN								varchar(4),
		Agent								varchar(4),
		AcctNo								varchar(16),
		AcctNoLast4							varchar(4),
		IFO_CROSS_REFERENCE_ACCT_NO			varchar(16),
		IFO_NEW_XREF_NO_1					varchar(16),
		IFO_NEW_XREF_NO_2					varchar(16),
		IFO_CUST_XREF_ID					varchar(16),
		IFO_MULTRAN_FLAG					varchar(1),
		AcctTransferJulianDate				varchar(5),
		AcctTransferFlag					varchar(1),
		PortfolioNo							varchar(4)
	);

	create unique clustered index uclx on #Base (AcctKey);

	create table #Cust
	(	AcctKey								bigint,

		--AltCustNo							varchar(23),
		--PrincipalName						varchar(26),
		--PrincipalLastName					varchar(26),
		--PrincipalFirstName					varchar(26),
		--SpouseName							varchar(26),
		--SpouseLastName						varchar(26),
		--SpouseFirstName						varchar(26),
		--IFO_ADDR_LINE_1						varchar(26),
		--IFO_ADDR_LINE_2						varchar(26),
		--IFO_CITY							varchar(18),
		--IFO_STATE							varchar(2),
		--IFO_ZIP_CODE						varchar(9),
		--IFO_SOC_SECURITY_NO					varchar(9)
		--IFO_TELEPHONE_NUMBER				varchar(10),
		--IFO_SECOND_TELEPHONE_NUMBER			varchar(10),
		--IFO_ADDRESS_FLAG					varchar(1),
		--IFO_HOME_PHONE_FLAG					varchar(1),
		--IFO_BUSINESS_PHONE_FLAG				varchar(1),
		--IFO_DECEASED_FLAG					varchar(1),
		--IFO_SOLICITATION_FLAG				varchar(1),
		--IFO_DATE_OF_BIRTH					date,
		--IFO_CTD_AMT_CASH					decimal(18,2),
		--IFO_CTD_AMT_LATE_CHG				decimal(18,2),
		--IFO_CTD_AMT_PAYMENT					decimal(18,2),
		--IFO_CTD_AMT_RETURN					decimal(18,2),
		--IFO_CTD_AMT_SALE					decimal(18,2),
		--IFO_CTD_UNPAID_BPD					decimal(18,2),
		--IFO_CTD_ANNUAL_CHARGE				decimal(18,2),
		--IFOAP_CURR_CTD_MRCH_PRIN			decimal(18,2),
		--IFOAP_CURR_CTD_CASH_PRIN			decimal(18,2),
		--IFO_ASSOC_CTD_NO_ADJ				int,
		--IFOHD_LATE_FEE_CTD					varchar(1),
		--IFO_ANNUAL_CHARGE_FLAG				varchar(1),
		--IFO_ANN_FEE_CHARGED					int,
		--IFO_ANNUAL_CHG_Date					int,
		--IFO_UNPD_ANNL_FEE_AM				decimal(18,2),
		--IFOAP_UNPD_ANNL_CHRG_AM				decimal(18,2),
		--IFO_CURR_ANNUAL_CHARGES_BILLED		decimal(18,2),
		--IFOHD_YTD_ANNUAL_CHG				decimal(18,2),
		--IFO_ANNL_CHRG_BLLD_LAST_DT			date,
		--IFOLS_LATE_CHG						decimal(18,2),
		--IFOPS_LATE_CHG						decimal(18,2),
		--IFOAP_UNPD_LATE_CHRG_AM				decimal(18,2),
		--IFOAP_Misc_Chgs						decimal(18,2),
		--IFO_CURR_OTHER_CHARGES_BILLED		decimal(18,2),
		--IFO_DATE_LAST_SALE					date,
		--IFOHD_AMT_LAST_SALE					decimal(18,2),
		--IFO_AUTH_TOTAL_AMT					decimal(18,2),
		--IFOBS_BPS_MIN_PAY_DUE				varchar(209),
		--IFO_PYMN_DUE_DT						date,
		--IFO_DATE_LAST_PAYMENT				date,
		--IFO_LST_PYMT_RVRS_DT				date,
		--IFO_AMT_LAST_PAYMENT				decimal(18,2),
		--IFO_MIN_PMNT_DUE_RT					decimal(18,2),
		--IFO_PREV_PYMT_AMT					decimal(18,2),
		--IFO_FIXED_PAYMENT_AMT				decimal(18,2),
		--IFO_PRMT_FIXD_PYMT_AM				decimal(18,2),
		--IFOLS_BILLED_PAY_DUE				decimal(18,2),
		--IFOPS_BILLED_PAY_DUE				decimal(18,2),
		--IFO_LAST_RET_CHECK					int,
		--IFO_RTRN_CHECK_DT					date,
		--IFOHD_TOTAL_RTRN_CHECKS_NO			int,
		--IFOHD_YTD_NO_RTRN_CHECKS			int,
		--IFOHD_PY_NO_RTRN_CHECKS				int,
		--IFOHD_MTHS_RTRN_CHECKS				int,
		--IFOHD_VD_NO_RTRN_CHECKS				int,
		--IFO_DESIGNATED_AUTOPAY_AMT			decimal(18,2),
		--IFO_TMPR_AUTO_PAY_AM				decimal(18,2),
		--IFO_LS_STIPULATED_AUTOPAY_AMT		decimal(18,2),
		--IFO_AUTOPAY_SKIP_FLAG				varchar(1),
		--IFO_LAST_AUTOPAY_DATE				varchar(4),
		--IFO_DDA_NM							varchar(22),
		--IFO_CHARGE_DDA_CODE					varchar(1),
		--IFO_TRANSIT_ROUTING_NO				varchar(9),
		--IFO_CHECKING_ACCT_NO				varchar(17),
		--IFO_SAVINGS_ACCT_NO					varchar(17),
		--IFO_EXTERNAL_STATUS					varchar(1),
		--IFO_INTERNAL_STATUS					varchar(1),
		--IFO_COFF_REASON_CODE				varchar(2),
		--IFO_PREV_EXT_STATUS					varchar(1),
		--IFO_PREV_STTS_RESN_CD				varchar(2),
		--IFO_DATE_STATUS_CHG					date,
		--IFO_COLLECTION_CODE					varchar(3),
		--Sort_Status							varchar(8),
		--IFO_REISSUE_CONTROL					varchar(1),
		--IFO_RENEWAL_CODE					varchar(1),
		--IFO_CURRENT_BALANCE					decimal(18,2),
		--DelinquentAmount5Days				decimal(18,2),
		--DelinquentAmount30Days				decimal(18,2),
		--DelinquentAmount60Days				decimal(18,2),
		--DelinquentAmount90Days				decimal(18,2),
		--DelinquentAmount120Days				decimal(18,2),
		--DelinquentAmount150Days				decimal(18,2),
		--DelinquentAmount180Days				decimal(18,2),
		--DelinquentAmount210Days				decimal(18,2),
		--DelinquentAmountTotal				decimal(18,2),
		--DelinquentCategoryCode				int,
		--DelinquentDays						int,
		--DelinquentItems						int,
		--DelinquentLastTime40Days			date,
		--DelinquentLastTime50Days			date,
		--DelinquentStartDate					date,
		--IFOHD_LF_1_12						varchar(12),
		--IFOHD_PH_1_12						varchar(12),
		--IFOHD_PH_13_24						varchar(12),
		--payhist24							varchar(24),
		--IFO_XCEPT_CHARGE_OFF_FLAG			varchar(1),
		--IFOHD_CHG_OFF_AMT					decimal(18,2),
		--IFOHD_CHG_OFF_DATE					date,
		--IFO_MON_RJCT_CD						varchar(1),
		--IFOHD_PRIR_REAG_DT					varchar(6),
		--IFOHD_DATE_LAST_REAGE				varchar(6),
		--IFOHD_PRVS_REAG_DT					varchar(6),
		--IFOHD_REAGE_NEXT_DATE				varchar(6),
		--IFO_CR_LINE_DATE					varchar(6),
		--IFO_PREV_CRLINE_CHANGE_DATE			varchar(6),
		--IFO_CASH_CREDIT_LINE_CHG_DT			date,
		--IFO_TMPR_CRDT_LINE_STRT_DT			date,
		--IFO_TMPR_CRDT_LINE_END_DT			date,
		--IFO_CREDIT_LINE						int,
		--IFO_TMPR_CRDT_LINE_AM				decimal(18,2),
		--IFO_CRLINE_CHANGE_AMT				decimal(18,2),
		--IFO_LAST_CR_LIMIT					int,
		--IFO_CASH_CRDT_LINE_AM				decimal(18,2),
		--IFO_TMPR_CRDT_LINE_CD				varchar(3),
		--IFO_TYPE_CRED_LINE_CHG				varchar(1),
		--IFO_CASH_CREDIT_LINE_CHG_TYP		varchar(1),
		--IFO_LAST_PLASTIC_SOURCE				varchar(1),
		--IFO_DUAL_TYPE_PLASTIC				varchar(1),
		--IFO_TYPE_PLASTIC					varchar(1),
		--IFO_DUAL_SPOUSE_TYPE_PLASTIC		varchar(1),
		--IFO_SPOUSE_TYPE_PLASTIC				varchar(1),
		--IFO_NO_PLASTICS						int,
		--IFO_OTST_PLST_CT					int,
		--IFO_DATE_LAST_PLASTIC				date,
		--IFO_STMT_HOLD_FLAG					varchar(1),
		--IFOBS_BPS_STMT_DATE					varchar(88),
		--IFOBS_BPS_STMT_BAL					varchar(209),
		--IFO_DATE_LAST_STMT					date,
		--IFO_EPMT_PART_IND_ID				varchar(1),
		--Electronic							varchar(1),
		--IFOLS_UNPAID_CASH_INTSC				decimal(18,2),
		--IFOLS_UNPAID_INTSC					decimal(18,2),
		--IFOLS_CASH_INT						decimal(18,2),
		--IFOLS_MRCH_INT						decimal(18,2),
		--IFOAP_OPEN_CYC_CASH_PRIN			decimal(18,2),
		--IFOAP_OPEN_CYC_MRCH_NBINT			decimal(18,2),
		--IFOAP_OPEN_CYC_MRCH_BINT			decimal(18,2),
		--IFO_LAST_STATEMENTED_BAL			decimal(18,2),
		--IFOLS_ADJUSTED_BALANCE				decimal(18,2),
		--IFO_LS_INTEREST_SWITCH				varchar(1),
		--IFOLS_IP_CASH_RATE_ANN				decimal(6,3),
		--IFOLS_IP_MRCH_RATE_ANN				decimal(6,3),
		--IFO_LS_MRCH_APR						decimal(6,3),
		--IFO_LS_CASH_APR						decimal(6,3),
		--IFO_LS_TEMP_MRCH_APR				decimal(6,3),
		--IFO_LS_TEMP_CASH_AP					decimal(6,3),
		--IFO_ANN_RATE_MRCH					decimal(6,3),
		--IFO_OPEN_DT							date,
		--IFO_EXPIRATION_DATE					date,
		--IFO_DATE_LOST_STOLEN				date,
		--IFO_DATE_LAST_PIN_MAILER			date,
		--IFO_DATE_LAST_NONMON				date,
		--IFO_DATE_LAST_MON_TRAN				date,
		--IFO_DATE_FIRST_ACT					date,
		--IFO_CREDBAL_START_DATE				date,
		--IFOHD_DATE_LAST_CASH				date,
		--IFO_CREDIT_LIFE_FLAG				varchar(1),
		--IFO_CR_LIFE_STATUS					varchar(1),
		--IFO_CR_LIFE_STATUS_DT				date,
		--IFO_CB_ID							varchar(1),
		--IFO_CB_CODE							varchar(4),
		--CreditScore					int,
		--IFO_CREDIT_BUREAU_FLAG				varchar(1),
		--IFO_CB_SCORE_DATE					date,
		--IFO_CB_SCORE						varchar(3),
		--IFO_UD_RISK_SCORE					varchar(3),
		--IFO_BEHAVIOR_SCORE					varchar(3),
		--IFO_PRICING_STRATEGY_LOCK_BEG		date,
		--IFO_PRICING_STRATEGY_LOCK_END		date,
		--IFO_CURR_PRICE_STRATEGY_DATE		date,
		--IFO_PRICING_STRATEGY_STATUS			varchar(1),
		--IFO_CURR_PRICING_STRATEGY			varchar(8),
		--IFO_LS_PRICING_STRATEGY				varchar(8),
		--IFOHD_PY_CHD_INTEREST				decimal(18,2),
		--IFO_DISPUTE_AMOUNT					decimal(18,2),
		--IFO_UD_PRODUCT_TYPE					varchar(3),
		--IFO_UD_SOURCE_CODE					varchar(4),
		--IFO_RANDOM_DIGITS					varchar(2),
		--IFO_DEBIT_ACTIVE					varchar(1),
		--IFO_BASIC_ACTIVE					varchar(1),
		--IFO_GROSS_ACTIVE					varchar(1),
		--IFO_AUTH_FLAG						varchar(1),
		--IFO_CORRESPOND_FLAG					varchar(1),
		--IFO_FDR_USE_MISC_FIELD_1			varchar(10),
		--IFO_MISCELLANEOUS_FIELD_1			varchar(4),
		--IFO_MISCELLANEOUS_FIELD_2			varchar(5),
		--IFO_MISCELLANEOUS_FIELD_3			varchar(7),
		--IFO_MISCELLANEOUS_FIELD_4			varchar(10),
		--IFO_MISCELLANEOUS_FIELD_5			varchar(8),
		--IFO_MISCELLANEOUS_FIELD_6			varchar(12),
		--IFO_MISCELLANEOUS_FIELD_7			varchar(10),
		--IFO_MISCELLANEOUS_FIELD_8			varchar(10),
		--IFO_MISC_FIELD_9					varchar(10),
		--IFO_MISC_FIELD_10					varchar(10),
		--IFO_MISC_FIELD_11_TX				varchar(26),
		--IFO_MISC_FIELD_12_TX				varchar(26),
		--IFO_SC_1							varchar(1),
		--IFO_SC_2							varchar(1),
		--IFO_SC_3							varchar(1),
		--IFO_SC_4							varchar(1),
		--IFO_SC_5							varchar(1),
		--IFO_SC_6							varchar(1),
		--IFO_SC_7							varchar(1),
		--IFO_SC_8							varchar(1),
		--IFO_CUST_FLG_1						varchar(1),
		--IFO_CUST_FLG_2						varchar(1),
		--IFO_CUST_FLG_3						varchar(1),
		--IFO_CUST_FLG_4						varchar(1),
		--IFO_UD_RPT1							varchar(4),
		--IFO_UD_RPT2							varchar(4),
		--IFO_UD_RPT3							varchar(4),
		--IFO_UD_RPT4							varchar(4),
		--IFO_UPC_1							varchar(1),
		--IFO_UPC_2							varchar(1),
		--IFO_UPC_3							varchar(1),
		--IFO_UPC_4							varchar(1),
		--IFO_UPC_5							varchar(1),
		--IFO_UPC_6							varchar(2),
		--IFO_UPC_7							varchar(2),
		--IFO_UPC_8							varchar(3),
		--IFO_UPC_10							varchar(4),
		--IFO_UPC_11							varchar(5),
		--IFO_UPC_12							varchar(6),
		--IFO_UPC_13							varchar(2),
		--IFOHD_LS_MDSE_ADB_AM				decimal(18,2),
		--IFOHD_LS_CASH_ADB_AM				decimal(18,2),
		--IFOHD_PS_MDSE_ADB_AM				decimal(18,2),
		--IFOHD_PS_CASH_ADB_AM				decimal(18,2)
--	);

--	create unique clustered index uclx on #Pass1 (FullAcctNo);

	create table #Pass2
	(	FullAcctNo						varchar(28),
		IFO_DATE_OF_BIRTH_SAS				int,
		IFO_NEXT_CYCL_DT_SAS				int,
		IFO_ANNL_CHRG_BLLD_LAST_DT_SAS		int,
		IFO_DATE_LAST_SALE_SAS				int,
		IFO_PYMN_DUE_DT_SAS					int,
		IFO_DATE_LAST_PAYMENT_SAS			int,
		IFO_LST_PYMT_RVRS_DT_SAS			int,
		IFO_RTRN_CHECK_DT_SAS				int,
		IFO_DATE_STATUS_CHG_SAS				int,
		DelinquentLastTime40DaysSas			int,
		DelinquentLastTime50DaysSas			int,
		DelinquentStartDateSas				int,
		IFOHD_CHG_OFF_DATE_SAS				int,
		IFO_CASH_CREDIT_LINE_CHG_DT_SAS		int,
		IFO_TMPR_CRDT_LINE_STRT_DT_SAS		int,
		IFO_TMPR_CRDT_LINE_END_DT_SAS		int,
		IFO_DATE_LAST_PLASTIC_SAS			int,
		IFO_DATE_LAST_STMT_SAS				int,
		IFO_OPEN_DT_SAS						int,
		IFO_EXPIRATION_DATE_SAS				int,
		IFO_DATE_LOST_STOLEN_SAS			int,
		IFO_DATE_LAST_PIN_MAILER_SAS		int,
		IFO_DATE_LAST_NONMON_SAS			int,
		IFO_DATE_LAST_MON_TRAN_SAS			int,
		IFO_DATE_FIRST_ACT_SAS				int,
		IFO_CREDBAL_START_DATE_SAS			int,
		IFOHD_DATE_LAST_CASH_SAS			int,
		IFO_CR_LIFE_STATUS_DT_SAS			int,
		IFO_CB_SCORE_DATE_SAS				int,
		IFO_PRICING_STRATEGY_LOCK_BEG_SAS	int,
		IFO_PRICING_STRATEGY_LOCK_END_SAS	int,
		IFO_CURR_PRICE_STRATEGY_DATE_SAS	int,
		reverse_payhist						varchar(24),
		Credit_Days							int,
		Days_Since_Payment					int,
		Open_Days							int,
		Phone								int,
		Pay									varchar(1),
		Activate							varchar(7),
		Prod_Type							varchar(16),
		ProductBrand						varchar(8),
		DelinquentCategoryDescription		varchar(12),
		CreditScoreCategoryDescription		varchar(13)
	);

	create unique clustered index uclx on #Pass2 (FullAcctNo);

	create table #Pass3
	(	FullAcctNo						varchar(28),
		FPD_e								varchar(1),
		SPD_e								varchar(1),
		NP_e								varchar(1),
		M6_e								varchar(1),
		FPD									varchar(1),
		SPD									varchar(1),
		M2D									varchar(1),
		NP									varchar(1),
		M6									varchar(1)
	);

	create unique clustered index uclx on #Pass3 (FullAcctNo);

	insert into #Dedupe
	select 
			AcctKey									=	cast (substring (b.IFO_BASE_FULL_ACCT_NO, 13, 16) as bigint),
			IFO_USER_TX								=	b.IFO_USER_TX,
			IFO_ACCT_CT								=	cast (
																case
																	when isnumeric (b.IFO_ACCT_CT) = 1
																	then substring (b.IFO_ACCT_CT, 2, 4)
																	else null
																end
																as int),
			Dedupe									=	row_number() over( partition by b.IFO_USER_TX order by b.IFO_ACCT_CT desc)

	from dbo.fdr_mf_base_jcf b

	declare @FullAcctNo				varchar(28) = '';
	declare @MyRowCount				int = 1;
	declare @MyProcessedRows		bigint = 0;

	while @MyRowCount > 0
	begin
		truncate table #Base;
		truncate table #Pass2;
		truncate table #Pass3;

		insert into #Base
		select top 100000
			AcctKey									=	cast (substring (b.IFO_BASE_FULL_ACCT_NO, 13, 16) as bigint),
			FullAcctNo								=	b.IFO_BASE_FULL_ACCT_NO,
			SystemId								=	substring (b.IFO_BASE_FULL_ACCT_NO, 1, 4),
			PRIN									=	substring (b.IFO_BASE_FULL_ACCT_NO, 5, 4),
			Agent									=	substring (b.IFO_BASE_FULL_ACCT_NO, 9, 4),
			AcctNo									=	substring (b.IFO_BASE_FULL_ACCT_NO, 13, 16),
			AcctNoLast4								=	substring (b.IFO_BASE_FULL_ACCT_NO, 25, 4),
			IFO_CROSS_REFERENCE_ACCT_NO				=	substring (b.IFO_CROSS_REFERENCE_ACCT_NO, 3, 16),
			IFO_NEW_XREF_NO_1						=	substring (b.IFO_NEW_XREF_NO_1, 3, 16),
			IFO_NEW_XREF_NO_2						=	substring (b.IFO_NEW_XREF_NO_2, 3, 16),
			IFO_CUST_XREF_ID						=	b.IFO_CUST_XREF_ID,
			IFO_MULTRAN_FLAG						=	b.IFO_MULTRAN_FLAG,
			AcctTransferJulianDate					=	coalesce (
															substring (b.IFO_ACCT_TRANSFER_DATE, 2, 5),
															null),
			AcctTransferFlag						=	b.IFO_ACCT_TRANSFER_FLAG,
			PortfolioNo								=	substring (b.IFO_PORTFOLIO_NO, 3, 4)

		from dbo.fdr_mf_base_jcf b
		where b.IFO_BASE_FULL_ACCT_NO > @FullAcctNo
		order by b.IFO_BASE_FULL_ACCT_NO
		set @MyRowCount = @@RowCount;
		set @MyProcessedRows += @MyRowCount;
		select @FullAcctNo = max(FullAcctNo) from #Base
		select @FullAcctNo, @MyRowCount, @MyProcessedRows;
	end;


		--from dbo.fdr_mf_base_jcf b			with (nolock)
	--	left join dbo.fdr_mf_cust_jcf c		with (nolock)	on b.IFO_BASE_FULL_ACCT_NO = c.IFO_CUST_FULL_ACCT_NO
	--	left join dbo.fdr_mf_curr_jcf cu	with (nolock)	on b.IFO_BASE_FULL_ACCT_NO = cu.IFO_CURR_FULL_ACCT_NO
	--	left join dbo.fdr_mf_hist_jcf h		with (nolock)	on b.IFO_BASE_FULL_ACCT_NO = h.IFO_HIST_FULL_ACCT_NO
	--	left join dbo.fdr_mf_beha_jcf be	with (nolock)	on b.IFO_BASE_FULL_ACCT_NO = be.IFO_BEHA_FULL_ACCT_NO
	--	left join dbo.fdr_mf_delq_jcf d		with (nolock)	on b.IFO_BASE_FULL_ACCT_NO = d.IFO_DELQ_FULL_ACCT_NO
	--	where b.IFO_USER_TX > @IFO_USER_TX
	--	order by b.IFO_USER_TX
	--	set @MyRowCount = @@RowCount;
	--	set @MyProcessedRows += @MyRowCount;
	--	select @IFO_USER_TX = max(IFO_USER_TX) from #Pass1
	--	select @IFO_USER_TX, @MyRowCount, @MyProcessedRows;

		--insert into #Pass2
		--select
		--	FullAcctNo							=	p1.FullAcctNo,
		--	IFO_DATE_OF_BIRTH_SAS					=	dbo.ToSasDateFromDate (p1.IFO_DATE_OF_BIRTH),
		--	IFO_NEXT_CYCL_DT_SAS					=	dbo.ToSasDateFromDate (p1.IFO_NEXT_CYCL_DT),
		--	IFO_ANNL_CHRG_BLLD_LAST_DT_SAS			=	dbo.ToSasDateFromDate (p1.IFO_ANNL_CHRG_BLLD_LAST_DT),
		--	IFO_DATE_LAST_SALE_SAS					=	dbo.ToSasDateFromDate (p1.IFO_DATE_LAST_SALE),
		--	IFO_PYMN_DUE_DT_SAS						=	dbo.ToSasDateFromDate (p1.IFO_PYMN_DUE_DT),
		--	IFO_DATE_LAST_PAYMENT_SAS				=	dbo.ToSasDateFromDate (p1.IFO_DATE_LAST_PAYMENT),
		--	IFO_LST_PYMT_RVRS_DT_SAS				=	dbo.ToSasDateFromDate (p1.IFO_LST_PYMT_RVRS_DT),
		--	IFO_RTRN_CHECK_DT_SAS					=	dbo.ToSasDateFromDate (p1.IFO_RTRN_CHECK_DT),
		--	IFO_DATE_STATUS_CHG_SAS					=	dbo.ToSasDateFromDate (p1.IFO_DATE_STATUS_CHG),
		--	DelinquentLastTime40DaysSas				=	dbo.ToSasDateFromDate (p1.DelinquentLastTime40Days),
		--	DelinquentLastTime50DaysSas				=	dbo.ToSasDateFromDate (p1.DelinquentLastTime50Days),
		--	DelinquentStartDateSas				=	dbo.ToSasDateFromDate (p1.DelinquentStartDate),
		--	IFOHD_CHG_OFF_DATE_SAS					=	dbo.ToSasDateFromDate (p1.IFOHD_CHG_OFF_DATE),
		--	IFO_CASH_CREDIT_LINE_CHG_DT_SAS			=	dbo.ToSasDateFromDate (p1.IFO_CASH_CREDIT_LINE_CHG_DT),
		--	IFO_TMPR_CRDT_LINE_STRT_DT_SAS			=	dbo.ToSasDateFromDate (p1.IFO_TMPR_CRDT_LINE_STRT_DT),
		--	IFO_TMPR_CRDT_LINE_END_DT_SAS			=	dbo.ToSasDateFromDate (p1.IFO_TMPR_CRDT_LINE_END_DT),
		--	IFO_DATE_LAST_PLASTIC_SAS				=	dbo.ToSasDateFromDate (p1.IFO_DATE_LAST_PLASTIC),
		--	IFO_DATE_LAST_STMT_SAS					=	dbo.ToSasDateFromDate (p1.IFO_DATE_LAST_STMT),
		--	IFO_OPEN_DT_SAS							=	dbo.ToSasDateFromDate (p1.IFO_OPEN_DT),
		--	IFO_EXPIRATION_DATE_SAS					=	dbo.ToSasDateFromDate (p1.IFO_EXPIRATION_DATE),
		--	IFO_DATE_LOST_STOLEN_SAS				=	dbo.ToSasDateFromDate (p1.IFO_DATE_LOST_STOLEN),
		--	IFO_DATE_LAST_PIN_MAILER_SAS			=	dbo.ToSasDateFromDate (p1.IFO_DATE_LAST_PIN_MAILER),
		--	IFO_DATE_LAST_NONMON_SAS				=	dbo.ToSasDateFromDate (p1.IFO_DATE_LAST_NONMON),
		--	IFO_DATE_LAST_MON_TRAN_SAS				=	dbo.ToSasDateFromDate (p1.IFO_DATE_LAST_MON_TRAN),
		--	IFO_DATE_FIRST_ACT_SAS					=	dbo.ToSasDateFromDate (p1.IFO_DATE_FIRST_ACT),
		--	IFO_CREDBAL_START_DATE_SAS				=	dbo.ToSasDateFromDate (p1.IFO_CREDBAL_START_DATE),
		--	IFOHD_DATE_LAST_CASH_SAS				=	dbo.ToSasDateFromDate (p1.IFOHD_DATE_LAST_CASH),
		--	IFO_CR_LIFE_STATUS_DT_SAS				=	dbo.ToSasDateFromDate (p1.IFO_CR_LIFE_STATUS_DT),
		--	IFO_CB_SCORE_DATE_SAS					=	dbo.ToSasDateFromDate (p1.IFO_CB_SCORE_DATE),
		--	IFO_PRICING_STRATEGY_LOCK_BEG_SAS		=	dbo.ToSasDateFromDate (p1.IFO_PRICING_STRATEGY_LOCK_BEG),
		--	IFO_PRICING_STRATEGY_LOCK_END_SAS		=	dbo.ToSasDateFromDate (p1.IFO_PRICING_STRATEGY_LOCK_END),
		--	IFO_CURR_PRICE_STRATEGY_DATE_SAS		=	dbo.ToSasDateFromDate (p1.IFO_CURR_PRICE_STRATEGY_DATE),
		--	reverse_payhist							=	reverse ( replace ( p1.payhist24, ' ', '')),
		--	Credit_Days								=	coalesce ( datediff ( day, p1.IFO_CREDBAL_START_DATE, getdate()), 0),
		--	Days_Since_Payment						=	coalesce ( datediff ( day, p1.IFO_DATE_LAST_PAYMENT, getdate()), 0),
		--	Open_Days								=	coalesce ( datediff ( day, p1.IFO_OPEN_DT, getdate()), 0),
		--	Phone									=	case
		--													when p1.IFO_TELEPHONE_NUMBER is null
		--													and p1.IFO_SECOND_TELEPHONE_NUMBER is null
		--													then 0
		--													when p1.IFO_TELEPHONE_NUMBER is not null
		--													and p1.IFO_SECOND_TELEPHONE_NUMBER is not null
		--													then 2
		--													else 1
		--												end,
		--	Pay										=	case
		--													when p1.IFO_DATE_LAST_PAYMENT is null
		--													then 'N'
		--													else 'Y'
		--												end,
		--	Activate								=	case
		--													when p1.IFO_CUST_FLG_4 not in ('N', 'T', ' ', 'R')
		--													then 'Y'
		--													when p1.IFO_CUST_FLG_4 in ('N', 'T', ' ', 'R')
		--													then
		--														case
		--															when p1.IFO_REISSUE_CONTROL in (3, 6)
		--															and p1.IFO_CUST_FLG_4 = 'R'
		--															then 'Y'
		--															when p1.IFO_DATE_LAST_SALE >= p1.IFO_OPEN_DT
		--															then 'Y'
		--															when p1.IFOHD_DATE_LAST_CASH >= p1.IFO_OPEN_DT
		--															then 'Y'
		--															when p1.IFO_OTST_PLST_CT = '0'
		--															then 'Y'
		--															else 'N'
		--														end
		--													else 'UNKNOWN'
		--												end,
		--	Prod_Type								=	case
		--													when p1.SystemId = '5360'
		--													then 'FS Card'
		--													when p1.SystemId = '1159' and p1.PRIN = '0000' and p1.Agent = '5000'
		--													then 'FIS Card'
		--													when PT.product_term_fdr_product_code is null
		--													then
		--														case
		--															when Agent = '4000'
		--															then 'New 750'
		--															when p1.IFO_OPEN_DT >= '3/1/2014'
		--															then 'New 500+'
		--															when p1.IFO_OPEN_DT < '3/1/2014'
		--															then 'Old 300'
		--															else 'Unknown'
		--														end
		--													when PT.product_term_fdr_product_code is not null
		--													then
		--														case
		--															when PT.product_term_open_date <= '4/30/2012'
		--															and PT.product_term_credit_limit = 300
		--															then 'Old 300'
		--															when PT.product_term_open_date > '4/30/2012'
		--															and PT.product_term_credit_limit = 300
		--															then 'New 300'
		--															when PT.product_term_credit_limit = 500
		--															then 'New 500+'
		--															when PT.product_term_credit_limit is not null
		--															then concat ('New ', cast(PT.product_term_credit_limit as varchar(4)))
		--															else 'Unknown'
		--														end
		--												end,
		--	ProductBrand							=	coalesce(PBD.ProductBrand,'Unknown'),
		--	DelinquentCategoryDescription			=	coalesce(DCD.DelinquentCategoryDescription, 'Unknown'),
		--	CreditScoreCategoryDescription			=	coalesce(CSCD.CreditScoreCategoryDescription, 'AA No Score')
														
		--from #Pass1 p1
		--left join dbo.Product_Term_JCF PT
		--on p1.IFO_UD_RPT4 = PT.product_term_fdr_product_code
		--left join dbo.ProductBrandDim_JCF PBD		on p1.IFO_UD_PRODUCT_TYPE = PBD.ProductType
		--left join dbo.DelinquentCategoryDim_JCF DCD	on p1.DelinquentCategoryCode = DCD.DelinquentCategoryCode
		--left join dbo.CreditScoreCategoryDim_JCF CSCD
		--		on p1.CreditScore
		--		between CSCD.CreditScoreCategoryStartRange
		--		and CSCD.CreditScoreCategoryStopRange
		--order by p1.FullAcctNo;

		--insert into #Pass3
		--select
		--	FullAcctNo							=	p2.FullAcctNo,
		--	FPD_e									=	case
		--													when substring ( p2.reverse_payhist, 2, 1) != ' '
		--													then 'Y'
		--													else 'N'
		--												end,
		--	SPD_e									=	case
		--													when substring ( p2.reverse_payhist, 3, 1) != ' '
		--													then 'Y'
		--													else 'N'
		--												end,
		--	NP_e									=	case
		--													when substring ( p2.reverse_payhist, 5, 1) != ' '
		--													then 'Y'
		--													else 'N'
		--												end,
		--	M6_e									=	case
		--													when substring ( p2.reverse_payhist, 7, 1) != ' '
		--													then 'Y'
		--													else 'N'
		--												end,
		--	FPD										=	case
		--													when substring ( p2.reverse_payhist, 2, 1) != ' '
		--													and substring ( p2.reverse_payhist, 1,2) = '01'
		--													then '1'
		--													else '0'
		--												end,
		--	SPD										=	case
		--													when substring ( p2.reverse_payhist, 3, 1) != ' '
		--													and substring ( p2.reverse_payhist, 1,3) = '012'
		--													then '1'
		--													else '0'
		--												end,
		--	M2D										=	case
		--													when substring ( p2.reverse_payhist, 3, 1) != ' '
		--													and substring ( p2.reverse_payhist, 1,3) = '001'
		--													then '1'
		--													else '0'
		--												end,
		--	NP										=	case
		--													when substring ( p2.reverse_payhist, 5, 1) != ' '
		--													and substring ( p2.reverse_payhist, 1,5) = '01234'
		--													then '1'
		--													else '0'
		--												end,
		--	M6										=	case
		--													when substring ( p2.reverse_payhist, 7, 1) != ' '
		--													and substring ( p2.reverse_payhist, 7, 1) >= '3'
		--													then '1'
		--													else '0'
		--												end

		--from #Pass2 p2
		--order by p2.FullAcctNo;


		--select
		--	p1.FullAcctNo,
			--p1.SystemId,
			--p1.PRIN,
			--p1.Agent,
			--p1.AcctNo,
			--p1.AcctNoLast4,
			--b.IFO_ACCT_CT,
			--p1.IFO_ACCT_CT,
			--p1.IFO_USER_TX,
			--b.IFO_CROSS_REFERENCE_ACCT_NO,
			--p1.IFO_CROSS_REFERENCE_ACCT_NO,
			--b.IFO_NEW_XREF_NO_1,
			--p1.IFO_NEW_XREF_NO_1,
			--b.IFO_NEW_XREF_NO_2,
			--p1.IFO_NEW_XREF_NO_2,
			--p1.IFO_MULTRAN_FLAG,
			--p1.IFO_CUST_XREF_ID,
			--b.IFO_ACCT_TRANSFER_DATE,
			--p1.AcctTransferJulianDate,
			--p1.AcctTransferFlag,
			--b.IFO_PORTFOLIO_NO,
			--p1.PortfolioNo,
			--p1.AltCustNo,
			--p1.PrincipalName,
			--p1.SpouseName,
			--p1.IFO_ADDR_LINE_1,
			--p1.IFO_ADDR_LINE_2,
			--p1.IFO_CITY,
			--p1.IFO_STATE,
			--p1.IFO_ZIP_CODE,
			--c.IFO_SOC_SECURITY_NO,
			--p1.IFO_SOC_SECURITY_NO,
			--c.IFO_TELEPHONE_NUMBER,
			--p1.IFO_TELEPHONE_NUMBER,
			--c.IFO_SECOND_TELEPHONE_NUMBER,
			--p1.IFO_SECOND_TELEPHONE_NUMBER,
			--p1.IFO_ADDRESS_FLAG,
			--p1.IFO_HOME_PHONE_FLAG,
			--p1.IFO_BUSINESS_PHONE_FLAG,
			--p1.IFO_DECEASED_FLAG,
			--p1.IFO_SOLICITATION_FLAG,
			--c.IFO_DATE_OF_BIRTH,
			--p1.IFO_DATE_OF_BIRTH,
			--p2.IFO_DATE_OF_BIRTH_SAS,
			--p1.IFO_CYCLE_CODE_99,
			--p1.IFO_PREVIOUS_CYCLE_CODE_99,
			--b.IFO_NEXT_CYCL_DT,
			--p1.IFO_NEXT_CYCL_DT,
			--p2.IFO_NEXT_CYCL_DT_SAS,
			--cu.IFO_CTD_AMT_CASH,
			--p1.IFO_CTD_AMT_CASH,
			--cu.IFO_CTD_AMT_LATE_CHG,
			--p1.IFO_CTD_AMT_LATE_CHG,
			--cu.IFO_CTD_AMT_PAYMENT,
			--p1.IFO_CTD_AMT_PAYMENT,
			--cu.IFO_CTD_AMT_RETURN,
			--p1.IFO_CTD_AMT_RETURN,
			--cu.IFO_CTD_AMT_SALE,
			--p1.IFO_CTD_AMT_SALE,
			--cu.IFO_CTD_UNPAID_BPD,
			--p1.IFO_CTD_UNPAID_BPD,
			--cu.IFO_CTD_ANNUAL_CHARGE,
			--p1.IFO_CTD_ANNUAL_CHARGE,
			--cu.IFOAP_CURR_CTD_MRCH_PRIN,
			--p1.IFOAP_CURR_CTD_MRCH_PRIN,
			--cu.IFOAP_CURR_CTD_CASH_PRIN,
			--p1.IFOAP_CURR_CTD_CASH_PRIN,
			--cu.IFO_ASSOC_CTD_NO_ADJ,
			--p1.IFO_ASSOC_CTD_NO_ADJ,
			--h.IFOHD_LATE_FEE_CTD,
			--p1.IFOHD_LATE_FEE_CTD,
			--p1.IFO_ANNUAL_CHARGE_FLAG,
			--b.IFO_ANN_FEE_CHARGED,
			--p1.IFO_ANN_FEE_CHARGED,
			--b.IFO_ANNUAL_CHG_Date,
			--p1.IFO_ANNUAL_CHG_Date,
			--b.IFO_UNPD_ANNL_FEE_AM,
			--p1.IFO_UNPD_ANNL_FEE_AM,
			--cu.IFOAP_UNPD_ANNL_CHRG_AM,
			--p1.IFOAP_UNPD_ANNL_CHRG_AM,
			--cu.IFO_CURR_ANNUAL_CHARGES_BILLED,
			--p1.IFO_CURR_ANNUAL_CHARGES_BILLED,
			--h.IFOHD_YTD_ANNUAL_CHG,
			--p1.IFOHD_YTD_ANNUAL_CHG,
			--h.IFO_ANNL_CHRG_BLLD_LAST_DT,
			--p1.IFO_ANNL_CHRG_BLLD_LAST_DT,
			--p2.IFO_ANNL_CHRG_BLLD_LAST_DT_SAS,
			--cu.IFOLS_LATE_CHG,
			--p1.IFOLS_LATE_CHG,
			--cu.IFOPS_LATE_CHG,
			--p1.IFOPS_LATE_CHG,
			--cu.IFOAP_UNPD_LATE_CHRG_AM,
			--p1.IFOAP_UNPD_LATE_CHRG_AM,
			--cu.IFOAP_Misc_Chgs,
			--p1.IFOAP_Misc_Chgs,
			--cu.IFO_CURR_OTHER_CHARGES_BILLED,
			--p1.IFO_CURR_OTHER_CHARGES_BILLED,
			--h.IFO_DATE_LAST_SALE,
			--p1.IFO_DATE_LAST_SALE,
			--p2.IFO_DATE_LAST_SALE_SAS,
			--h.IFOHD_AMT_LAST_SALE,
			--p1.IFOHD_AMT_LAST_SALE,
			--h.IFO_AUTH_TOTAL_AMT,
			--p1.IFO_AUTH_TOTAL_AMT,
			--p1.IFOBS_BPS_MIN_PAY_DUE,
			--b.IFO_PYMN_DUE_DT,
			--p1.IFO_PYMN_DUE_DT,
			--p2.IFO_PYMN_DUE_DT_SAS,
			--h.IFO_DATE_LAST_PAYMENT,
			--p1.IFO_DATE_LAST_PAYMENT,
			--p2.IFO_DATE_LAST_PAYMENT_SAS,
			--h.IFO_LST_PYMT_RVRS_DT,
			--p1.IFO_LST_PYMT_RVRS_DT,
			--p2.IFO_LST_PYMT_RVRS_DT_SAS,
			--h.IFO_AMT_LAST_PAYMENT,
			--p1.IFO_AMT_LAST_PAYMENT,
			--b.IFO_MIN_PMNT_DUE_RT,
			--p1.IFO_MIN_PMNT_DUE_RT,
			--b.IFO_PREV_PYMT_AMT,
			--p1.IFO_PREV_PYMT_AMT,
			--b.IFO_FIXED_PAYMENT_AMT,
			--p1.IFO_FIXED_PAYMENT_AMT,
			--cu.IFO_PRMT_FIXD_PYMT_AM,
			--p1.IFO_PRMT_FIXD_PYMT_AM,
			--cu.IFOLS_BILLED_PAY_DUE,
			--p1.IFOLS_BILLED_PAY_DUE,
			--cu.IFOPS_BILLED_PAY_DUE,
			--p1.IFOPS_BILLED_PAY_DUE,
			--b.IFO_LAST_RET_CHECK,
			--p1.IFO_LAST_RET_CHECK,
			--h.IFO_RTRN_CHECK_DT,
			--p1.IFO_RTRN_CHECK_DT,
			--p2.IFO_RTRN_CHECK_DT_SAS,
			--h.IFOHD_TOTAL_RTRN_CHECKS_NO,
			--p1.IFOHD_TOTAL_RTRN_CHECKS_NO,
			--h.IFOHD_YTD_NO_RTRN_CHECKS,
			--p1.IFOHD_YTD_NO_RTRN_CHECKS,
			--h.IFOHD_PY_NO_RTRN_CHECKS,
			--p1.IFOHD_PY_NO_RTRN_CHECKS,
			--h.IFOHD_MTHS_RTRN_CHECKS,
			--p1.IFOHD_MTHS_RTRN_CHECKS,
			--h.IFOHD_VD_NO_RTRN_CHECKS,
			--p1.IFOHD_VD_NO_RTRN_CHECKS,
			--b.IFO_DESIGNATED_AUTOPAY_AMT,
			--p1.IFO_DESIGNATED_AUTOPAY_AMT,
			--b.IFO_TMPR_AUTO_PAY_AM,
			--p1.IFO_TMPR_AUTO_PAY_AM,
			--h.IFO_LS_STIPULATED_AUTOPAY_AMT,
			--p1.IFO_LS_STIPULATED_AUTOPAY_AMT,
			--p1.IFO_AUTOPAY_SKIP_FLAG,
			--p1.IFO_LAST_AUTOPAY_DATE,
			--p1.IFO_DDA_NM,
			--p1.IFO_CHARGE_DDA_CODE,
			--b.IFO_TRANSIT_ROUTING_NO,
			--p1.IFO_TRANSIT_ROUTING_NO,
			--p1.IFO_CHECKING_ACCT_NO,
			--p1.IFO_SAVINGS_ACCT_NO,
			--p1.IFO_EXTERNAL_STATUS,
			--p1.IFO_INTERNAL_STATUS,
			--p1.IFO_COFF_REASON_CODE,
			--p1.IFO_PREV_EXT_STATUS,
			--p1.IFO_PREV_STTS_RESN_CD,
			--b.IFO_DATE_STATUS_CHG,
			--p1.IFO_DATE_STATUS_CHG,
			--p2.IFO_DATE_STATUS_CHG_SAS,
			--b.IFO_COLLECTION_CODE,
			--p1.IFO_COLLECTION_CODE,
			--p1.Sort_Status,
			--b.IFO_REISSUE_CONTROL,
			--p1.IFO_REISSUE_CONTROL,
			--b.IFO_RENEWAL_CODE,
			--p1.IFO_RENEWAL_CODE,
			--cu.IFO_CURRENT_BALANCE,
			--p1.IFO_CURRENT_BALANCE,
			--d.IFO_DEL_AMT_DAY5,
			--p1.DelinquentAmount5Days,
			--d.IFO_DEL_AMT_DAY30,
			--p1.DelinquentAmount30Days,
			--d.IFO_DEL_AMT_DAY60,
			--p1.DelinquentAmount60Days,
			--d.IFO_DEL_AMT_DAY90,
			--p1.DelinquentAmount90Days,
			--d.IFO_DEL_AMT_DAY120,
			--p1.DelinquentAmount120Days,
			--d.IFO_DEL_AMT_DAY150,
			--p1.DelinquentAmount150Days,
			--d.IFO_DEL_AMT_DAY180,
			--p1.DelinquentAmount180Days,
			--d.IFO_DEL_AMT_DAY210,
			--p1.DelinquentAmount210Days,
			--d.IFO_DEL_AMT_TOT,
			--p1.DelinquentAmountTotal,
			--d.IFO_DEL_NO_CYCLES,
			--p1.DelinquentCategoryCode,
			--d.IFO_DEL_NO_DAYS,
			--p1.DelinquentDays,
			--d.IFO_DEL_NO_ITEMS,
			--p1.DelinquentItems,
			--h.IFO_LAST_40_DAY_DLNQ_DT,
			--p1.DelinquentLastTime40Days,
			--p2.DelinquentLastTime40DaysSas,
			--h.IFO_LAST_50_DAY_DLNQ_DT,
			--p1.DelinquentLastTime50Days,
			--p2.DelinquentLastTime50DaysSas,
			--b.IFO_START_DATE_OF_DELQ,
			--p1.DelinquentStartDate,
			--p2.DelinquentStartDateSas,
			--h.IFOHD_LF_1_12,
			--p1.IFOHD_LF_1_12,
			--h.IFOHD_PH_1_12,
			--p1.IFOHD_PH_1_12,
			--h.IFOHD_PH_13_24,
			--p1.IFOHD_PH_13_24,
			--len(h.IFOHD_PH_13_24),
			--len(p1.IFOHD_PH_13_24),
			--p1.payhist24,
			--p1.IFO_XCEPT_CHARGE_OFF_FLAG,
			--h.IFOHD_CHG_OFF_AMT,
			--p1.IFOHD_CHG_OFF_AMT,
			--h.IFOHD_CHG_OFF_DATE,
			--p1.IFOHD_CHG_OFF_DATE,
			--p2.IFOHD_CHG_OFF_DATE_SAS,
			--p1.IFO_MON_RJCT_CD,
			--h.IFOHD_PRIR_REAG_DT,
			--p1.IFOHD_PRIR_REAG_DT,
			--h.IFOHD_DATE_LAST_REAGE,
			--p1.IFOHD_DATE_LAST_REAGE,
			--h.IFOHD_PRVS_REAG_DT,
			--p1.IFOHD_PRVS_REAG_DT,
			--h.IFOHD_REAGE_NEXT_DATE,
			--p1.IFOHD_REAGE_NEXT_DATE,
			--b.IFO_CR_LINE_DATE,
			--p1.IFO_CR_LINE_DATE,
			--b.IFO_PREV_CRLINE_CHANGE_DATE,
			--p1.IFO_PREV_CRLINE_CHANGE_DATE,
		--	b.IFO_CASH_CREDIT_LINE_CHG_DT,
		--	p1.IFO_CASH_CREDIT_LINE_CHG_DT,
		--	p2.IFO_CASH_CREDIT_LINE_CHG_DT_SAS,
		--	b.IFO_TMPR_CRDT_LINE_STRT_DT,
		--	p1.IFO_TMPR_CRDT_LINE_STRT_DT,
		--	p2.IFO_TMPR_CRDT_LINE_STRT_DT_SAS,
		--	b.IFO_TMPR_CRDT_LINE_END_DT,
		--	p1.IFO_TMPR_CRDT_LINE_END_DT,
		--	p2.IFO_TMPR_CRDT_LINE_END_DT_SAS,

		--select
		--	p1.FullAcctNo,

		--	--c.IFO_TELEPHONE_NUMBER,
		--	--len(c.IFO_TELEPHONE_NUMBER),
		--	--p1.IFO_TELEPHONE_NUMBER,
		--	--c.IFO_SECOND_TELEPHONE_NUMBER,
		--	--len(c.IFO_SECOND_TELEPHONE_NUMBER),
		--	--p1.IFO_SECOND_TELEPHONE_NUMBER,
		--	--p2.Phone

		--	--h.IFO_DATE_LAST_PAYMENT,
		--	--len(h.IFO_DATE_LAST_PAYMENT),
		--	--p1.IFO_DATE_LAST_PAYMENT,
		--	--p2.Pay

		--	--p1.IFO_CUST_FLG_4,
		--	--len(p1.IFO_CUST_FLG_4),
		--	--p1.IFO_REISSUE_CONTROL,
		--	--p1.IFO_DATE_LAST_SALE,
		--	--p1.IFOHD_DATE_LAST_CASH,
		--	--p1.IFO_OPEN_DT,
		--	--p2.Activate,
		--	--p1.IFO_UD_RPT4,
		--	--p2.Prod_Type,
		--	--b.IFO_UD_PRODUCT_TYPE,
		--	--p1.IFO_UD_PRODUCT_TYPE,
		--	--p2.ProductBrand,
		--	--d.IFO_DEL_NO_CYCLES,
		--	--p1.DelinquentCategoryCode,
		--	--p2.DelinquentCategoryDescription,
		--	--b.IFO_CREDIT_SCORE,
		--	--p1.CreditScore,
		--	--p2.CreditScoreCategoryDescription,

		--	p1.IFO_USER_TX,
		--	p1.IFO_ACCT_CT,
		--	p1.Dedupe

		--from #Pass1 p1
		--left join #Pass2 p2									on p1.FullAcctNo		= p2.FullAcctNo
		--join Warehouse.dbo.fdr_mf_base_20201101 b			on p1.FullAcctNo		= b.IFO_BASE_FULL_ACCT_NO
		--left join Warehouse.dbo.fdr_mf_cust_20201101 c		on b.IFO_BASE_FULL_ACCT_NO	= c.IFO_CUST_FULL_ACCT_NO
		--left join Warehouse.dbo.fdr_mf_curr_20201101 cu		on b.IFO_BASE_FULL_ACCT_NO	= cu.IFO_CURR_FULL_ACCT_NO
		--left join Warehouse.dbo.fdr_mf_hist_20201101 h		on b.IFO_BASE_FULL_ACCT_NO	= h.IFO_HIST_FULL_ACCT_NO
		--left join Warehouse.dbo.fdr_mf_beha_20201101 be		on b.IFO_BASE_FULL_ACCT_NO	= be.IFO_BEHA_FULL_ACCT_NO
		--left join Warehouse.dbo.fdr_mf_delq_20201101 d		on b.IFO_BASE_FULL_ACCT_NO	= d.IFO_DELQ_FULL_ACCT_NO
		--order by p1.IFO_USER_TX, p1.IFO_ACCT_CT

--		set @MyRowCount = 0;
	--end;

--END
GO
