CREATE OR replace FUNCTION "Datediff" 
	(p_what  IN VARCHAR2, 
		p_start IN DATE, 
		p_end   IN DATE) 
RETURN NUMBER 
AS 
  v_result NUMBER; 
BEGIN 

		if

    IF ( Upper(p_what) = 'YEAR' ) THEN 
      SELECT Months_between(Trunc(p_end, 'YEAR'), Trunc(p_start, 'YEAR')) / 12 
      INTO   v_result 
      FROM   dual; 
    ELSIF ( Upper(p_what) = 'MONTH' ) THEN 
      SELECT Months_between(Trunc(p_end, 'MONTH'), Trunc(p_start, 'MONTH')) 
      INTO   v_result 
      FROM   dual; 
    ELSIF ( Upper(p_what) = 'DAY' ) THEN 
      SELECT Trunc(p_end) - Trunc(p_start) 
      INTO   v_result 
      FROM   dual; 
    ELSE 
      v_result := NULL; 
    END IF; 

    RETURN Trunc(v_result); 
END; 