create or replace PROCEDURE USPUMVALIDATEUSER (
    IN_TENANTCODE IN NVarchar2,
    IN_USERNAME IN Varchar2,
    IN_PASSWORD IN Varchar2,
    IN_LASTLOGIN IN Varchar2,
    OUT_USERID OUT Varchar2,
    OUT_TENANTKEY OUT Varchar2,
    OUT_VALIDATERESULT OUT Varchar2)
AS
/*
SELECT p.UserID, p.OUT_VALIDATERESULT
FROM USPUMVALIDATEUSER('MC', 'vk6', '20111201090000', 'VK6') p
*/

/******************************************************************************
**  File:        uspUMValidateUser
**  Description: Validate VKUser Password
**  Returns:     
**  Params:      
**               @Passward - The password of the user
**               @Username - The name of the  user
**               @ApplicationName
*******************************************************************************
**  Change History
*******************************************************************************
**	Author	        Date	    TFS	    Description
**	Luke		    2010/06/10	n/a  	Original.
**	
*******************************************************************************
**	Author	        Date				    Description
**	Luke				2010/12/10 		update after review.
**	Marco			2014/01/15		add logincount
**	Marco			2014/12/19		Convert to oracle
**	Marco			2015/02/07		Fix 7 day fitler issue
**	Marco			2015/07/06		Make password case-sensitive
**  Jerry Chen    2015/07/06        N/A     Add tenantkey
**  Jerry Chen    2015/07/08        N/A     get lock information from VKUSER
**  Jerry Chen    2015/07/13        N/A     If user name does not exists, return NULLUSER
**  Jerry Chen    2015/07/21        N/A     get right minute from date
**  Jerry Chen    2015/07/22        N/A     check tenant active and customer role
**  Jerry Chen    2015/07/24        N/A     if user login succeed, then the lock information should be cleared.
**	Jerry Chen		2015/11/20      DE15317     Lock time issue - minus value shows up
**	Marco			2016/05/16		Clear user session template/inernal when login
**	Jerry Chen      2017/03/20  US201598  VKC: RedTeam Test - Weak Password Storage
**  Jerry Chen      2017/05/16  N/A  when get user roleID, should add tenant key as condition
**	Marco Cao		2015/07/06 count customer login owner/plant 
**  Jerry Chen      2017/05/16  US250544  VKC: Make default tenant settings and customer role settings
**  Jerry Chen      2018/04/11  US266674	VKC: Session Template/Internal is not cleared if user login with super password
**	Ben Song			2018/05/03			US317749 VKV:Owner/Plant page, the VKV Logins and Last Login columns...verify the query
*******************************************************************************/
PWD VARCHAR2(50);
SALTPASSWORD VARCHAR2(50);
ISLOCKEDOUT CHAR(1);
PASSWORDEXPIRES CHAR(1);
v_LASTLOGIN VARCHAR2(20);
LASTLOGINDIFFDATE INTEGER;
OWNERKEY VARCHAR2(40);
PLANTKEY VARCHAR2(40);
OWNERKEY2 VARCHAR2(40);
PLANTKEY2 VARCHAR2(40);
ALLOP CHAR(1);
KEYTYPE VARCHAR2(50);
ROWCOUNT NUMBER(10);
v_FILTERDAY NUMBER(10);
V_LOCKDATE timestamp;
V_TIMELEFT NUMBER(10);

V_ACTIVE VARCHAR2(50);
V_CUSTOMER_ACTIVE VARCHAR2(50);
V_CUSTOMERROLEONLY VARCHAR2(50);
V_ROLEID VARCHAR2(50);
V_ROLENAME  VARCHAR2(50);

V_ISCUSTOMER CHAR(1);
v_KeyType VARCHAR2(20);
v_OK VARCHAR2(40);
v_PK VARCHAR2(40);
BEGIN
    OUT_VALIDATERESULT := 'False';    
	
  BEGIN    
    SELECT UNIQUEKEY, ACTIVE, CUSTOMER_ACTIVE, CUSTOMERROLEONLY
    INTO OUT_TENANTKEY, V_ACTIVE, V_CUSTOMER_ACTIVE, V_CUSTOMERROLEONLY
    FROM TENANT WHERE UPPER(TENANT_CODE)=UPPER(IN_TENANTCODE);
  
    SELECT	USERID, "PASSWORD", SALTPASSWORD, ISLOCKEDOUT, PASSWORDEXPIRES, LASTLOGIN, LASTLOCKEDOUTDATE
      INTO	OUT_USERID, PWD, SALTPASSWORD, ISLOCKEDOUT, PASSWORDEXPIRES, v_LASTLOGIN, V_LOCKDATE
    FROM	VKUSER
      WHERE	UPPER(USERNAME) = UPPER(IN_UserName)
       AND		TENANTKEY = OUT_TENANTKEY;
    EXCEPTION
      WHEN no_data_found
      THEN
      OUT_USERID := NULL;
  END; 
  SELECT  round(extract( day from diff )*24*60 + extract( hour from diff )*60 + extract( minute from diff ) ) INTO V_TIMELEFT from (select (systimestamp - to_timestamp(V_LOCKDATE)) diff from dual);
  IF  abs(V_TIMELEFT) >= 30 THEN
    BEGIN
      --ISLOCKEDOUT := 'F';
      UPDATE VKUSER 
      SET FAILEDPWDATTEMPTCOUNT = null, LASTLOCKEDOUTDATE = null
      WHERE UPPER(USERNAME) = UPPER(IN_UserName)
        AND	TENANTKEY = OUT_TENANTKEY;
        V_LOCKDATE := null;
    END;
  END IF;
      

	IF LENGTH(v_LASTLOGIN) = 14 THEN
		LASTLOGINDIFFDATE := V_TIMELEFT;
	END IF;
  
  IF OUT_USERID IS NULL THEN
    OUT_VALIDATERESULT := 'NULLUSER';
  ELSIF ISLOCKEDOUT = 'T' THEN
    OUT_VALIDATERESULT := 'USERISPREVENTLOGIN';
  ELSIF V_LOCKDATE is not null THEN
    OUT_VALIDATERESULT := 'Locked;' || (30 - V_TIMELEFT);
  ELSIF PASSWORDEXPIRES = 'T' AND LASTLOGINDIFFDATE > 90 THEN
    OUT_VALIDATERESULT := 'Expired';
  ELSIF (PWD <> IN_Password) THEN
    OUT_VALIDATERESULT := 'False';
  ELSE
    BEGIN
      SELECT ROLEID INTO V_ROLEID FROM VKUSERROLE WHERE USERID=OUT_USERID AND TENANTKEY = OUT_TENANTKEY;
      SELECT R.ROLENAME, ISCUSTOMER INTO V_ROLENAME, V_ISCUSTOMER
          FROM VKROLE R LEFT JOIN VKUSERROLE U ON 
          R.ROLEID = U.ROLEID  AND U.USERID = OUT_USERID AND U.TENANTKEY = OUT_TENANTKEY
          where R.TENANTKEY = OUT_TENANTKEY AND R.ROLEID=V_ROLEID;
  
      IF (V_ACTIVE <> 'T') THEN
      BEGIN
        OUT_VALIDATERESULT := 'ACTIVETENANT';
      END;
      ELSIF(V_CUSTOMERROLEONLY = 'T') THEN
      BEGIN
        IF(V_ROLENAME = 'Customer') THEN
            OUT_VALIDATERESULT := 'True';
        ELSE
            OUT_VALIDATERESULT := 'CUSTOMERROLEONLY';
        END IF;
      END;      
      ELSE
        OUT_VALIDATERESULT := 'True';
      END IF;
    END;
  END IF;
  -- Clear user session template/inernal when login
  IF (OUT_VALIDATERESULT <> 'NULLUSER') THEN
    UPDATE	USERPREFERENCE
    SET		SESSIONTEMPLATEID = NULL, SESSIONINTERNALID = NULL
    WHERE	USERKEY = OUT_USERID AND TENANTKEY = OUT_TENANTKEY;
  END IF;
	IF OUT_VALIDATERESULT = 'True' THEN 


		SELECT	COUNT(*)	INTO	ROWCOUNT
		FROM	AccessPlants
		WHERE	USERID = OUT_USERID AND		TENANTKEY = OUT_TENANTKEY;


		IF ROWCOUNT = 0 THEN
			SELECT	EX9, EX10, ALLOP
			INTO	OWNERKEY, PLANTKEY, ALLOP
			FROM	USERID
			WHERE	UPPER(USERNAME) = UPPER(IN_UserName) AND TENANTKEY=OUT_TENANTKEY;
			

			IF ALLOP = 'T' THEN
				KEYTYPE := 'AllOwners';
				OWNERKEY := NULL;
				PLANTKEY := NULL;
			ELSIF COALESCE(PLANTKEY, '') <> '' AND PLANTKEY <> 'ALL' THEN
				KEYTYPE := 'SinglePlant';
			ELSIF (COALESCE(OWNERKEY, '') <> '' AND OWNERKEY <> 'ALL') THEN
				KEYTYPE := 'SingleOwner';
				PLANTKEY := NULL;
			ELSE
				KEYTYPE := 'None';
				OWNERKEY := NULL;
				PLANTKEY := NULL;
      END IF;

			INSERT INTO AccessPlants
			(UserID,TENANTKEY,KeyType,	OwnerKey,PlantKey)
			VALUES
			(OUT_USERID,  OUT_TENANTKEY,KEYTYPE,OWNERKEY,PLANTKEY);	

			DELETE FROM	WorkingPlants
			WHERE	USERID = OUT_USERID AND		TENANTKEY = OUT_TENANTKEY;

			INSERT INTO WorkingPlants
			(	UserID, TENANTKEY,KeyType,	OwnerKey,PlantKey)
			VALUES
			(OUT_USERID, OUT_TENANTKEY,KEYTYPE,	OWNERKEY,	PLANTKEY);

			IF KEYTYPE = 'AllOwners' THEN
				OWNERKEY2 := 'ALL';
				PLANTKEY2 := 'ALL';
			ELSIF KEYTYPE = 'None' THEN
				OWNERKEY2 := 'NONE';
				PLANTKEY2 := 'NONE';
			ELSIF KEYTYPE = 'SingleOwner' THEN
				OWNERKEY2 := OWNERKEY;
				PLANTKEY2 := 'ALL';
			ELSIF KEYTYPE = 'SinglePlant' THEN
				OWNERKEY2 := OWNERKEY;
				PLANTKEY2 := PLANTKEY;
			END IF;

			UPDATE	VKUSER
			SET		OWNERKEY = OWNERKEY2,	PLANTKEY = PLANTKEY2
			WHERE	USERID = OUT_USERID AND		TENANTKEY = OUT_TENANTKEY;

			USPCLEARALLFILTERS(OUT_USERID);

			DELETE FROM	RECENTLYITEM			WHERE	USERKEY = OUT_USERID AND		TENANTKEY = OUT_TENANTKEY;
		END IF;

		SELECT	COUNT(*) INTO ROWCOUNT
		FROM	WorkingPlants
		WHERE	USERID = OUT_USERID AND		TENANTKEY = OUT_TENANTKEY;

		IF ROWCOUNT = 0 THEN
			INSERT INTO WorkingPlants
			(UserID,  TENANTKEY,KeyType,	OwnerKey,PlantKey)
			SELECT	UserID, TENANTKEY, KeyType, OwnerKey, PlantKey
			FROM	AccessPlants
			WHERE	USERID = OUT_USERID AND		TENANTKEY = OUT_TENANTKEY;

			USPCLEARALLFILTERS(OUT_USERID);

			DELETE	FROM	RECENTLYITEM
			WHERE	USERKEY = OUT_USERID AND		TENANTKEY = OUT_TENANTKEY;
		END IF;
    
	--count customer login owner/plant 
	IF V_ISCUSTOMER = 'T' THEN
		BEGIN
		SELECT KeyType, OwnerKey, PlantKey INTO v_KeyType, v_OK, v_PK FROM WorkingPlants  
			  WHERE UserID = OUT_USERID AND ROWNUM=1 AND TENANTKEY=OUT_TENANTKEY;
		EXCEPTION
		  WHEN no_data_found
		  THEN
			v_KeyType := NULL;
			v_OK := NULL;
			v_PK := NULL; 
		END; 

	  UPDATE	VKUSER
		SET		LASTLOGIN = IN_LastLogin, LOGINCOUNT = LOGINCOUNT +1,
         FAILEDPWDATTEMPTCOUNT = null, ISLOCKEDOUT='F', LASTLOCKEDOUTDATE = null
		WHERE	USERID = OUT_USERID AND		TENANTKEY = OUT_TENANTKEY;
        
		IF (v_KeyType = 'SingleOwner') THEN
			UPDATE OWNERS SET EI1=DECODE(EI1,null,0,EI1)+1, E1=IN_LastLogin WHERE TENANTKEY=OUT_TENANTKEY AND UniqueKey = v_OK;
		ELSIF (v_KeyType = 'SinglePlant') THEN
			UPDATE OWNERS SET EI1=DECODE(EI1,null,0,EI1)+1, E1=IN_LastLogin WHERE TENANTKEY=OUT_TENANTKEY AND UniqueKey = v_OK;
			UPDATE PLANTS SET EI1=DECODE(EI1,null,0,EI1)+1, E1=IN_LastLogin WHERE TENANTKEY=OUT_TENANTKEY AND OwnerKey = v_OK   AND UniqueKey = v_PK;
		END IF;
	END IF;

  BEGIN
		SELECT	FILTERDAY INTO v_FILTERDAY
		FROM	USERPREFERENCE
		WHERE	USERKEY = OUT_USERID AND		TENANTKEY = OUT_TENANTKEY;
    EXCEPTION
      WHEN no_data_found
      THEN
      v_FILTERDAY := NULL;
  END; 
	IF v_FILTERDAY IS NOT NULL THEN
		IF LASTLOGINDIFFDATE > 7 THEN
			USPCLEARALLFILTERS(OUT_USERID);
			UPDATE	USERPREFERENCE	SET		FILTERDAY = NULL
			WHERE	USERKEY = OUT_USERID AND		TENANTKEY = OUT_TENANTKEY;
		END IF; 
	ELSE
		IF LASTLOGINDIFFDATE > 1 THEN
			USPCLEARALLFILTERS(OUT_USERID);
    END IF;
  END IF;
  END IF;
	
END USPUMVALIDATEUSER;