SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ========================================================
-- Author:		Joe Flasher - White Dog SQL Consulting, LLC
-- Create date: 5/3/2021
-- Description:	Load PersonFact.
-- For:			Continental Finance Company, LLC
-- ========================================================
CREATE OR ALTER PROCEDURE dbo.LoadPersonFact (@BatchSize int = 100000)
AS
BEGIN

SET NOCOUNT ON;

Declare @Step int = 1,
		@ProcedureName varchar(100) = (Select name from sys.objects where object_id = @@PROCID),
		@RunSize int = 1000000;

--
--	Load Applicants into ApplicantsAndCustomers.
--
insert into dbo.ApplicantsAndCustomers
select top 1000
--ComboKey
	Convert(bigint, A.applicant_id) as ComboKey,
--Type
	'A' as Type,
--AccountNumber
	0 as AccountNumber,
--ApplicantId
	A.applicant_id as ApplicantId,
--SocialSecurityNumber
	A.applicant_ssn as SocialSecurityNumber,
--BirthDate
	A.applicant_dob as BirthDate,
--BirthDateSas
	dbo.ToSasDateFromDate (A.applicant_dob) as BirthDateSas,
--PrincipalFirstName
	case
		when CHARINDEX(' ', A.applicant_fname) > 0
		then SUBSTRING(A.applicant_fname, 1, CHARINDEX(' ', A.applicant_fname) - 1)
		else A.applicant_fname
	end as PrincipalFirstName,
--SoundsLikeFirstName
	case
		when CHARINDEX(' ', A.applicant_fname) > 0
		then SOUNDEX(SUBSTRING(A.applicant_fname, 1, CHARINDEX(' ', A.applicant_fname) - 1))
		else SOUNDEX(A.applicant_fname)
	end as SoundsLikeFirstName,
--PrincipalLastName
	case
		when CHARINDEX(' ', A.applicant_lname) > 0
		then SUBSTRING(A.applicant_lname, 1, CHARINDEX(' ', A.applicant_lname) - 1)
		else A.applicant_lname
	end as PrincipalLastName,
--SoundsLikeLastName
	case
		when CHARINDEX(' ', A.applicant_lname) > 0
		then SOUNDEX(SUBSTRING(A.applicant_lname, 1, CHARINDEX(' ', A.applicant_lname) - 1))
		else SOUNDEX(A.applicant_lname)
	end as SoundsLikeLastName,
--AddressLine1
	A.applicant_address1 as AddressLine1,
--AddressLine2
	A.applicant_address2 as AddressLine2,
--City
	A.applicant_city as City,
--State
	A.applicant_state as State,
--ZipCode
	A.applicant_zip as ZipCode,
--Zip5
	substring(A.applicant_zip,1,5) as Zip5,
--FraudHold
	A.applicant_fraud_hold as FraudHold,
--ActivityDate
	A.applicant_appln_date as ActivityDate
from dbo.applicant_JCF A
left join dbo.ApplicantsAndCustomers AC
on A.applicant_id = AC.ComboKey
where AC.ComboKey is null;

Exec @Step = dbo.WriteToProcessLog @@PROCID, @ProcedureName, @Step, 'Insert applications into ApplicantsAndCustomers', @@ROWCOUNT;

END
GO

--
--	Load Customers into ApplicantsAndCustomers.
--
Insert into dbo.ApplicantsAndCustomers
select
--ComboKey
	Convert(bigint, substring (B.IFO_BASE_FULL_ACCT_NO, 13, 16)) as ComboKey,
--Type
	'C' as Type,
--AccountNumber
	Convert(bigint, substring (B.IFO_BASE_FULL_ACCT_NO, 13, 16)) as AccountNumber,
--ApplicantId
	A.applicant_id as ApplicantId,
--SocialSecurityNumber
	C.IFO_SOC_SECURITY_NO as SocialSecurityNumber,
--BirthDate
	C.IFO_DATE_OF_BIRTH as BirthDate,
--BirthDateSas
	dbo.ToSasDateFromDate (C.IFO_DATE_OF_BIRTH) as BirthDateSas,
--PrincipalFirstName
	case
		when CHARINDEX(' ', C.IFO_PRINCIPAL_NAME) > 0
		then SUBSTRING(C.IFO_PRINCIPAL_NAME, 1, CHARINDEX(' ', C.IFO_PRINCIPAL_NAME) - 1)
		else C.IFO_PRINCIPAL_NAME
	end as PrincipalFirstName,
--SoundsLikeFirstName
	case
		when CHARINDEX(' ', C.IFO_PRINCIPAL_NAME) > 0
		then SOUNDEX(SUBSTRING(C.IFO_PRINCIPAL_NAME, 1, CHARINDEX(' ', C.IFO_PRINCIPAL_NAME) - 1))
		else SOUNDEX(C.IFO_PRINCIPAL_NAME)
	end as SoundsLikeFirstName,
--PrincipalLastName
	case
		when CHARINDEX(' ', C.IFO_PRINCIPAL_NAME) > 0
		then SUBSTRING(C.IFO_PRINCIPAL_NAME, 1, CHARINDEX(' ', C.IFO_PRINCIPAL_NAME) - 1)
		else C.IFO_PRINCIPAL_NAME
	end as PrincipalLastName,
--SoundsLikeLastName
	case
		when CHARINDEX(' ', C.IFO_PRINCIPAL_NAME) > 0
		then SOUNDEX(SUBSTRING(C.IFO_PRINCIPAL_NAME, 1, CHARINDEX(' ', C.IFO_PRINCIPAL_NAME) - 1))
		else SOUNDEX(C.IFO_PRINCIPAL_NAME)
	end as SoundsLikeLastName,
--AddressLine1
	C.IFO_ADDR_LINE_1 as AddressLine1,
--AddressLine2
	C.IFO_ADDR_LINE_2 as AddressLine2,
--City
	C.IFO_CITY as City,
--State
	C.IFO_STATE as State,
--ZipCode
	C.IFO_ZIP_CODE as ZipCode,
--Zip5
	substring(C.IFO_ZIP_CODE,1,5) as Zip5,
--FraudHold
	A.applicant_fraud_hold as FraudHold,
--ActivityDate
	B.IFO_OPEN_DT as ActivityDate
from dbo.fdr_mf_cust_jcf C
left join dbo.fdr_mf_base_jcf B
on C.IFO_CUST_FULL_ACCT_NO = B.IFO_BASE_FULL_ACCT_NO
left join dbo.applicant_JCF A
on A.applicant_id =
	case
		when substring (B.IFO_BASE_FULL_ACCT_NO, 1, 4) = '5360'
		then B.IFO_MISC_FIELD_9
		else B.IFO_MISCELLANEOUS_FIELD_8
	end;

Exec @Step = dbo.WriteToProcessLog @@PROCID, @ProcedureName, @Step, 'Insert customer accounts into ApplicantsAndCustomers', @@ROWCOUNT;

drop table if exists [dbo].[PersonIds];

create table [dbo].[PersonIds]
(	ComboKey				bigint,
	Type					varchar(1),
	AccountNumber			bigint,
	ApplicantId				int,
	FraudHold				bit,
	PersonId				bigint,
	SocialSecurityNumber	varchar(9),
	Birthdate				date,
	BirthdateSas			int,
	FirstName				varchar(50),
	SoundsLikeFirstName		char(4),
	LastName				varchar(50),
	SoundsLikeLastName		char(4),
	AddressLine1			varchar(50),
	AddressLine2			varchar(50),
	City					varchar(50),
	State					varchar(2),
	ZipCode					varchar(9),
	Zip5					varchar(5),
	ActivityDate			datetime2(0),
	MatchPriority			int,
	MatchedAccountNumber	bigint,
	MatchedApplicantId		int,
	CreateDatetime			datetime2
) ON [POC];

CREATE UNIQUE CLUSTERED INDEX [UCLX_ComboKey]
ON [dbo].[PersonIds] (ComboKey)
WITH (DROP_EXISTING = OFF) ON [POC]

declare	@Type					varchar(1),
		@ComboKey				bigint,
		@AccountNumber			bigint,
		@ApplicantId			int,
		@FraudHold				bit,
		@PersonId				bigint,
		@SocialSecurityNumber	varchar(9),
		@Birthdate				date,
		@BirthdateSas			int,
		@FirstName				varchar(50),
		@SoundsLikeFirstName	char(4),
		@LastName				varchar(50),
		@SoundsLikeLastName		char(4),
		@AddressLine1			varchar(50),
		@AddressLine2			varchar(50),
		@City					varchar(50),
		@State					varchar(2),
		@ZipCode				varchar(9),
		@Zip5					varchar(5),
		@ActivityDate			Datetime2(0),
		@MatchPriority			int,
		@MatchedAccountNumber	bigint,
		@MatchedApplicantId		int,
		@MatchType				varchar(1),
		@MatchComboKey			bigint,
		@MyCount				bigint = 0

declare ApplicantsAndCustomers_cursor cursor
	for select
--ComboKey
			ComboKey,
--Type
			Type,
--AccountNumber
			AccountNumber,
--ApplicantId
			ApplicantId,
--FraudHold
			FraudHold,
--SocialSecurityNumber
			SocialSecurityNumber,
--Birthdate
			Birthdate,
--BirthdateSas
			BirthdateSas,
--FirstName
			FirstName,
--SoundsLikeFirstName
			SoundsLikeFirstName,
--LastName
			LastName,
--SoundsLikeLastName
			SoundsLikeLastName,
--AddressLine1
			AddressLine1,
--AddressLine2
			AddressLine2,
--City
			City,
--State
			State,
--ZipCode
			ZipCode,
--Zip5
			Zip5,
--ActivityDate
			ActivityDate
		from dbo.ApplicantsAndCustomers
		--where SocialSecurityNumber in ('007640838','027584689','032542020','040586812','045589645','046880786',
		--'051701602','052609404','056668624','056742060','072689845','080582579','102828165','122789544','122925240',
		--'132708372','143842901','145526827','149668252','154705835','174542078','182561345','192735962','205568339',
		--'206523034','220944960','224986896','239134394','240539433','241923707','252452387','267571053','267829412',
		--'278706450','307665146','319784705','323589343','328666493','341365619','346709205','365808667','378259643',
		--'396804051','404215606','409848031','417528408','419112587','426419752','427618023','438067504','441622488',
		--'442562908','451536641','459555043','483044209','512626453','512906527','518061246','532803532','553172792',
		--'558275477','560114532','560816222','567332438','583010979','592050983','592726434','596037630','601366309',
		--'603180761','612339466','634301590')
		order by ActivityDate

open ApplicantsAndCustomers_cursor

print concat(convert(varchar(24),getdate(),108), ' Duration = ', Convert(varchar(20),DateDiff(SECOND,@StopWatch,getdate())), ' Open ApplicantsAndCustomers_cursor.')
set @StopWatch = getdate();

fetch next from ApplicantsAndCustomers_cursor
	into @ComboKey, @Type, @AccountNumber, @ApplicantId, @FraudHold, @SocialSecurityNumber, @Birthdate, @BirthdateSas,
		@FirstName, @SoundsLikeFirstName, @LastName, @SoundsLikeLastName,
		@AddressLine1, @AddressLine2, @City, @State, @ZipCode, @Zip5, @ActivityDate

print concat(convert(varchar(24),getdate(),108), ' Duration = ', Convert(varchar(20),DateDiff(SECOND,@StopWatch,getdate())), ' Fetch first from ApplicantsAndCustomers_cursor.')
set @StopWatch = getdate();

begin transaction

while @@FETCH_STATUS = 0 --and @MyCount < @RunSize
begin
	if @MyCount % @BatchSize = 0 and @MyCount > 0
	Begin
		commit transaction
		print concat(convert(varchar(24),getdate(),108), ' Duration = ', Convert(varchar(20),DateDiff(SECOND,@StopWatch,getdate())), ' Batch ',convert(varchar(10),@MyCount))
		set @StopWatch = getdate();
		begin transaction
	End

	set @MyCount = @MyCount + 1
	set @PersonId = null
	set @MatchPriority = 0

	select @PersonId = PersonId
	from dbo.PersonIds
	where ComboKey = @ComboKey
--
--	1. Match on SSN, Birthdate, First & Last Name
--
	If @MatchPriority = 0
	Begin
		Select top 1 @MatchComboKey = ComboKey, @MatchType = Type, @MatchPriority = 1
		from dbo.ApplicantsAndCustomers
		where SocialSecurityNumber = @SocialSecurityNumber
		and	BirthdateSas = @BirthdateSas
		and	FirstName = @FirstName
		and	LastName = @LastName
		and ComboKey != @ComboKey
		and ActivityDate <= @ActivityDate
		order by Type desc, ActivityDate
	End
--
--	2. Match on SSN, First & Last Name
--
	If @MatchPriority = 0
	Begin
		Select top 1 @MatchComboKey = ComboKey, @MatchType = Type, @MatchPriority = 2
		from dbo.ApplicantsAndCustomers
		where SocialSecurityNumber = @SocialSecurityNumber
		and	FirstName = @FirstName
		and	LastName = @LastName
		and ComboKey != @ComboKey
		and ActivityDate <= @ActivityDate
		order by Type desc, ActivityDate
	End
--
--	3. Match on Birthdate, First & Last Name
--
	If @MatchPriority = 0
	Begin
		Select top 1 @MatchComboKey = ComboKey, @MatchType = Type, @MatchPriority = 3
		from dbo.ApplicantsAndCustomers
		where BirthdateSas = @BirthdateSas
		and	FirstName = @FirstName
		and	LastName = @LastName
		and ComboKey != @ComboKey
		and ActivityDate <= @ActivityDate
		order by Type desc, ActivityDate
	End
--
--	4. Match on SSN, First, Zip
--
	If @MatchPriority = 0
	Begin
		Select top 1 @MatchComboKey = ComboKey, @MatchType = Type, @MatchPriority = 4
		from dbo.ApplicantsAndCustomers
		where SocialSecurityNumber = @SocialSecurityNumber
		and	FirstName = @FirstName
		and	Zip5 = @Zip5
		and ComboKey != @ComboKey
		and ActivityDate <= @ActivityDate
		order by Type desc, ActivityDate
	End
--
--	5. Match on SSN, Last, Zip
--
	If @MatchPriority = 0
	Begin
		Select top 1 @MatchComboKey = ComboKey, @MatchType = Type, @MatchPriority = 5
		from dbo.ApplicantsAndCustomers
		where SocialSecurityNumber = @SocialSecurityNumber
		and	LastName = @LastName
		and	Zip5 = @Zip5
		and ComboKey != @ComboKey
		and ActivityDate <= @ActivityDate
		order by Type desc, ActivityDate
	End
--
--	6. Match on SSN, Birthdate, First Sound & Last Sound
--
	If @MatchPriority = 0
	Begin
		Select top 1 @MatchComboKey = ComboKey, @MatchType = Type, @MatchPriority = 6
		from dbo.ApplicantsAndCustomers
		where SocialSecurityNumber = @SocialSecurityNumber
		and	BirthdateSas = @BirthdateSas
		and	SoundsLikeFirstName = @SoundsLikeFirstName
		and	SoundsLikeLastName = @SoundsLikeLastName
		and ComboKey != @ComboKey
		and ActivityDate <= @ActivityDate
		order by Type desc, ActivityDate
	End
--
--	7. Match on SSN, First Sound & Last Sound
--
	If @MatchPriority = 0
	Begin
		Select top 1 @MatchComboKey = ComboKey, @MatchType = Type, @MatchPriority = 7
		from dbo.ApplicantsAndCustomers
		where SocialSecurityNumber = @SocialSecurityNumber
		and	SoundsLikeFirstName = @SoundsLikeFirstName
		and	SoundsLikeLastName = @SoundsLikeLastName
		and ComboKey != @ComboKey
		and ActivityDate <= @ActivityDate
		order by Type desc, ActivityDate
	End
--
--	8. Match on Birthdate, First Sound & Last Sound
--
	If @MatchPriority = 0
	Begin
		Select top 1 @MatchComboKey = ComboKey, @MatchType = Type, @MatchPriority = 8
		from dbo.ApplicantsAndCustomers
		where BirthdateSas = @BirthdateSas
		and	SoundsLikeFirstName = @SoundsLikeFirstName
		and	SoundsLikeLastName = @SoundsLikeLastName
		and ComboKey != @ComboKey
		and ActivityDate <= @ActivityDate
		order by Type desc, ActivityDate
	End
--
--	9. Match on SSN, First Sound, Zip
--
	If @MatchPriority = 0
	Begin
		Select top 1 @MatchComboKey = ComboKey, @MatchType = Type, @MatchPriority = 9
		from dbo.ApplicantsAndCustomers
		where SocialSecurityNumber = @SocialSecurityNumber
		and	SoundsLikeFirstName = @SoundsLikeFirstName
		and	Zip5 = @Zip5
		and ComboKey != @ComboKey
		and ActivityDate <= @ActivityDate
		order by Type desc, ActivityDate
	End
--
-- 10. Match on SSN, Last Sound, Zip
--
	If @MatchPriority = 0
	Begin
		Select top 1 @MatchComboKey = ComboKey, @MatchType = Type, @MatchPriority = 10
		from dbo.ApplicantsAndCustomers
		where SocialSecurityNumber = @SocialSecurityNumber
		and	SoundsLikeLastName = @SoundsLikeLastName
		and	Zip5 = @Zip5
		and ComboKey != @ComboKey
		and ActivityDate <= @ActivityDate
		order by Type desc, ActivityDate
	End
--
-- 11. Match on SSN, Birthdate, First Sound & Last Sound
--
	If @MatchPriority = 0
	Begin
		Select top 1 @MatchComboKey = ComboKey, @MatchType = Type, @MatchPriority = 11
		from dbo.ApplicantsAndCustomers
		where SocialSecurityNumber = @SocialSecurityNumber
		and	BirthdateSas = @BirthdateSas
		and	Difference(FirstName, @FirstName) >= 3
		and	Difference(LastName, @LastName) >= 3
		and ComboKey != @ComboKey
		and ActivityDate <= @ActivityDate
		order by Type desc, ActivityDate
	End
--
-- 12. Match on SSN, First Sound & Last Sound
--
	If @MatchPriority = 0
	Begin
		Select top 1 @MatchComboKey = ComboKey, @MatchType = Type, @MatchPriority = 12
		from dbo.ApplicantsAndCustomers
		where SocialSecurityNumber = @SocialSecurityNumber
		and	Difference(FirstName, @FirstName) >= 3
		and	Difference(LastName, @LastName) >= 3
		and ComboKey != @ComboKey
		and ActivityDate <= @ActivityDate
		order by Type desc, ActivityDate
	End
--
-- 13. Match on Birthdate, First Sound & Last Sound
--
	If @MatchPriority = 0
	Begin
		Select top 1 @MatchComboKey = ComboKey, @MatchType = Type, @MatchPriority = 13
		from dbo.ApplicantsAndCustomers
		where BirthdateSas = @BirthdateSas
		and	Difference(FirstName, @FirstName) >= 3
		and	Difference(LastName, @LastName) >= 3
		and ComboKey != @ComboKey
		and ActivityDate <= @ActivityDate
		order by Type desc, ActivityDate
	End
--
-- 14. Match on SSN, First Sound, Zip
--
	If @MatchPriority = 0
	Begin
		Select top 1 @MatchComboKey = ComboKey, @MatchType = Type, @MatchPriority = 14
		from dbo.ApplicantsAndCustomers
		where SocialSecurityNumber = @SocialSecurityNumber
		and	Difference(FirstName, @FirstName) >= 3
		and	Zip5 = @Zip5
		and ComboKey != @ComboKey
		and ActivityDate <= @ActivityDate
		order by Type desc, ActivityDate
	End
--
-- 15. Match on SSN, Last Sound, Zip
--
	If @MatchPriority = 0
	Begin
		Select top 1 @MatchComboKey = ComboKey, @MatchType = Type, @MatchPriority = 15
		from dbo.ApplicantsAndCustomers
		where SocialSecurityNumber = @SocialSecurityNumber
		and	Difference(LastName, @LastName) >= 3
		and	Zip5 = @Zip5
		and ComboKey != @ComboKey
		and ActivityDate <= @ActivityDate
		order by Type desc, ActivityDate
	End
--
-- 16. Match on SSN, Birthdate, First sounds like Last, Last sounds like First
--
	If @MatchPriority = 0
	Begin
		Select top 1 @MatchComboKey = ComboKey, @MatchType = Type, @MatchPriority = 16
		from dbo.ApplicantsAndCustomers
		where SocialSecurityNumber = @SocialSecurityNumber
		and	BirthdateSas = @BirthdateSas
		and	SoundsLikeFirstName = @SoundsLikeLastName
		and	SoundsLikeLastName = @SoundsLikeFirstName
		and ComboKey != @ComboKey
		and ActivityDate <= @ActivityDate
		order by Type desc, ActivityDate
	End

	If @MatchPriority > 0
	Begin
		Select top 1 @PersonId = PersonId, @MatchedAccountNumber = AccountNumber, @MatchedApplicantId = ApplicantId
		from dbo.PersonIds
		where ComboKey = @MatchComboKey
	End

	If @PersonId is null
	Begin
		Select @PersonId = Next Value For dbo.PersonIdSequence;

		Set @MatchPriority = 0;
		Set @MatchedAccountNumber = @AccountNumber;
		Set @MatchedApplicantId = @ApplicantId;
	End

	insert into dbo.PersonIds
	select	ComboKey = @ComboKey,
			Type = @Type,
			AccountNumber = @AccountNumber,
			ApplicantId = @ApplicantId,
			FraudHold = @FraudHold,
			PersonId = @PersonId,
			SocialSecurityNumber = @SocialSecurityNumber,
			Birthdate = @Birthdate,
			BirthdateSas = @BirthdateSas,
			FirstName = @FirstName,
			SoundsLikeFirstName = @SoundsLikeFirstName,
			LastName = @LastName,
			SoundsLikeLastName = @SoundsLikeLastName,
			AddressLine1 = @AddressLine1,
			AddressLine2 = @AddressLine2,
			City = @City,
			State = @State,
			ZipCode = @ZipCode,
			Zip5 = @Zip5,
			ActivityDate = @ActivityDate,
			MatchPriority = @MatchPriority,
			MatchedAccountNumber = @MatchedAccountNumber,
			MatchedApplicantId = @MatchedApplicantId,
			CreateDatetime = getdate()

	fetch next from ApplicantsAndCustomers_cursor
		into @ComboKey, @Type, @AccountNumber, @ApplicantId, @FraudHold, @SocialSecurityNumber, @Birthdate, @BirthdateSas,
			@FirstName, @SoundsLikeFirstName, @LastName, @SoundsLikeLastName,
			@AddressLine1, @AddressLine2, @City, @State, @ZipCode, @Zip5, @ActivityDate
end

commit transaction
print concat(convert(varchar(24),getdate(),108), ' Duration = ', Convert(varchar(20),DateDiff(SECOND,@StopWatch,getdate())), ' Batch ',convert(varchar(10),@MyCount))
set @StopWatch = getdate();

close ApplicantsAndCustomers_cursor
deallocate ApplicantsAndCustomers_cursor

print concat(convert(varchar(24),getdate(),108), ' Duration = ', Convert(varchar(20),DateDiff(SECOND,@StartTime,getdate())))
print concat(convert(varchar(24),getdate(),108), ' Done')
