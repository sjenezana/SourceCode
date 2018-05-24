 
			SELECT  'MUL' UNIQUEKEY, n'Multi Owners' OWNERNAME  FROM DUAL
			UNION ALL
			SELECT  'ALL' UNIQUEKEY, n'All Owners' OWNERNAME  FROM DUAL
			UNION ALL
			SELECT * FROM (
			SELECT	o.UNIQUEKEY, nvl(o.OWNERNAME,'') AS OWNERNAME
			FROM	OWNERS o
			WHERE	o.TENANTKEY = '61E39FA31A874996B8597CDCC06735E9'  
			ORDER BY UPPER(OWNERNAME));
 
			SELECT  'MUL' UNIQUEKEY, n'Multi Owners' OWNERNAME  FROM DUAL
			UNION ALL
			SELECT  'ALL' UNIQUEKEY, n'All Owners' OWNERNAME  FROM DUAL
			UNION ALL
			SELECT * FROM (
				SELECT	distinct o.UNIQUEKEY, nvl(o.OWNERNAME, '') AS OWNERNAME
				FROM	OWNERS o
				JOIN	ACCESSPLANTS a ON (a.OWNERKEY = o.UNIQUEKEY)
				WHERE	o.TENANTKEY = '61E39FA31A874996B8597CDCC06735E9'  
				AND		a.USERID = '648700140121852200'
				ORDER BY UPPER(OWNERNAME));
 
			SELECT	o.UNIQUEKEY,
					COALESCE(TO_CHAR(o.OWNERNAME), '') AS OWNERNAME
			FROM	OWNERS o
			WHERE	o.TENANTKEY = '61E39FA31A874996B8597CDCC06735E9'  
			ORDER BY UPPER(OWNERNAME);
 
			SELECT	distinct o.UNIQUEKEY,
					COALESCE(TO_CHAR(o.OWNERNAME), '') AS OWNERNAME
			FROM	OWNERS o
			JOIN	ACCESSPLANTS a ON (a.OWNERKEY = o.UNIQUEKEY)
			WHERE	o.TENANTKEY = '61E39FA31A874996B8597CDCC06735E9'  
			AND		a.USERID = '648700140121852200'
			ORDER BY UPPER(OWNERNAME);
 