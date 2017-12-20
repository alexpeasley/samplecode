USE [fw]
GO

/****** Object:  StoredProcedure [dbo].[sp_GetNavitusPatientInformation]    Script Date: 12/19/2017 9:18:12 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




/*****************************************************************************************
PROCEDURE:	dbo.sp_GetMonthlyPremium

PURPOSE: Retrieve patient data for ENR067ETF
          

PARMS:       None

REVISIONS:			

	DATE		    AUTHOR				      DESCRIPTION
******************************************************************************************
	20160517    ALEX PEALEY           PROGRAM CREATION
	20160912	AP					  UPDATED LOGIC TO REMOVE NAVITUS_ID FROM IDENTITY QUERY
******************************************************************************************/
CREATE PROCEDURE [dbo].[sp_GetNavitusPatientInformation]
	-- Add the parameters for the stored procedure here

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

	SET NOCOUNT ON;
DECLARE @SSN VARCHAR(9)

SELECT 
	PAT_FIRST_NAME,
	PAT_LAST_NAME,
	BIRTH_DATE,
	SSN,
	NAVITUS_ID,
	PCP_PROV_ID,
	PROV_NAME
 FROM (SELECT 
	PATIENT.PAT_FIRST_NAME,
	PATIENT.PAT_LAST_NAME, 
	PATIENT.BIRTH_DATE,
	REPLACE(PATIENT.SSN,'-','') AS SSN,
	IDENTITY_ID.IDENTITY_ID AS NAVITUS_ID,
	VL_PAT_PCP.PCP_PROV_ID,
	PCP_CLARITY_SER.PROV_NAME,
	IDENTITY_TYPE_ID,
	 RANK()  OVER (  PARTITION BY REPLACE(PATIENT.SSN,'-','') ORDER BY IDENTITY_ID.IDENTITY_ID) AS [RecordRank]
	
FROM 
	clarity.dbo.PATIENT
	INNER JOIN clarity.dbo.IDENTITY_ID
		ON PATIENT.PAT_ID = IDENTITY_ID.PAT_ID
	LEFT OUTER JOIN fw.dbo.VL_PAT_PCP
      ON VL_PAT_PCP.PAT_ID = PATIENT.PAT_ID
    LEFT OUTER JOIN Clarity.dbo.CLARITY_SER AS PCP_CLARITY_SER
      ON PCP_CLARITY_SER.PROV_ID = VL_PAT_PCP.PCP_PROV_ID
WHERE 
	--IDENTITY_TYPE_ID in ( 18,0)
 PATIENT.SSN IS NOT NULL
	) A
WHERE 
A.RecordRank = 1




END


GO


