
---TABLA DONDE SE INSERTAN LOS VALORES
CREATE TABLE RESUME_Q_TABLE (
COMPANY  VARCHAR2(50), Q1  NUMBER, RANGE_Q1 VARCHAR2(30), VARIATION_Q1 NUMBER,BEST_DAY_Q1 VARCHAR2(30), 
Q2 NUMBER, RANGE_Q2 VARCHAR2(30), VARIATION_Q2 NUMBER,BEST_DAY_Q2 VARCHAR2(30), 
Q3 NUMBER, RANGE_Q3 VARCHAR2(30), VARIATION_Q3 NUMBER,BEST_DAY_Q3 VARCHAR2(30), 
Q4 NUMBER, RANGE_Q4 VARCHAR2(30), VARIATION_Q4 NUMBER, BEST_DAY_Q4 VARCHAR2(30), 
BEST_Q_MILLIONS VARCHAR2(30));



------------------CREACION DEL PACKAGE--------------------------------------------
CREATE OR REPLACE PACKAGE  BOLSA_VALORES AS
PROCEDURE RESUMEN_BOLSA(ANIO IN NUMBER);
END BOLSA_VALORES;

-----------------BODY DEL PACKEGE-------------------------------------------
CREATE OR REPLACE PACKAGE BODY  BOLSA_VALORES AS

-------------------PROCEDIMIENTO PARA CALCULAR LOS VALORES------------------------------------------------------
procedure get_values_q(empresa in BOLSA_VALOR.COMPANY%TYPE,anio in number,
                                v_q1 out number,q_range1 out varchar2,var1 out number, best_day1 out date,
                                v_q2 out number,q_range2 out varchar2,var2 out number, best_day2 out date,
                                v_q3 out number,q_range3 out varchar2,var3 out number, best_day3 out date,
                                v_q4 out number,q_range4 out varchar2,var4 out number, best_day4 out date,
                                Q_best_mill out varchar2)
is

avg_alto BOLSA_VALOR.ALTO%TYPE;
avg_bajo BOLSA_VALOR.BAJO%TYPE;
max_alto BOLSA_VALOR.ALTO%TYPE;
min_bajo BOLSA_VALOR.BAJO%TYPE;
avg_open BOLSA_VALOR.ABIERTO%TYPE;
avg_close BOLSA_VALOR.CERRADO%TYPE;
avg_vol BOLSA_VALOR.volumen%TYPE;
avg_adj BOLSA_VALOR.adj_close%TYPE;
max_vol BOLSA_VALOR.volumen%TYPE;

--valores a calcular;
v_q  number;-- VALOR DE Q
q_range varchar2(30);--RANGO DEL VALOR
variation number;-- VARIACION
Q_mill number;--Q EN MILLIONS
Q_mill_aux number:=0;--Q MILLONS AUXILIAR PARA DETERMINAR SI EL NUEVO VALOR ES MAS ALTO  QUE EL ANTERIOR
best_day date;

max_mes number;
min_mes number;

begin

for quarter in 1..4 loop

max_mes:=3*quarter;
min_mes:=max_mes-2;

select avg(alto),avg(bajo),trunc(max(alto),3),trunc(min(bajo),3) 
into avg_alto,avg_bajo,max_alto,min_bajo from BOLSA_VALOR
WHERE EXTRACT(MONTH FROM FECHA) between min_mes and max_mes AND EXTRACT(YEAR FROM FECHA)=anio AND
COMPANY=empresa;

select avg(abierto),avg(cerrado),avg(volumen),avg(adj_close)
into avg_open, avg_close,avg_vol,avg_adj from BOLSA_VALOR
WHERE EXTRACT(MONTH FROM FECHA) between min_mes and max_mes AND EXTRACT(YEAR FROM FECHA)=anio AND
COMPANY=empresa;

--BEST DAY--
select max(volumen) into max_vol from BOLSA_VALOR
WHERE EXTRACT(MONTH FROM FECHA) between min_mes and max_mes AND EXTRACT(YEAR FROM FECHA)=anio AND
COMPANY=empresa;

select fecha into best_day from BOLSA_VALOR
WHERE EXTRACT(MONTH FROM FECHA) between min_mes and max_mes AND EXTRACT(YEAR FROM FECHA)=anio AND
COMPANY = empresa AND volumen=max_vol;

----CALCULO DE VALORES PARA INSERTAR A TABLA
v_q :=trunc((avg_alto+avg_bajo)/2,3);-- VALOR DE Q
q_range := min_bajo||' - '||max_alto;--RANGO DEL VALOR
variation := trunc(avg_open - avg_close,3);-- VARIACION
Q_mill := trunc(avg_vol*avg_adj/1000000,3);--Q EN MILLIONS

--HALLAR MAXIMO Q_MILLONES
if Q_mill>Q_mill_aux then

    Q_best_mill := 'Q'||quarter||'= '||Q_mill;
    Q_mill_aux :=Q_mill;
end if;

--ASIGNACION DE RESULTADOS A VARIABLES
if quarter=1 then
    v_q1 := v_q;
    q_range1 :=q_range;
    var1:= variation;
    best_day1 :=best_day;

elsif quarter=2 then 
    v_q2 := v_q;
    q_range2:=q_range;
    var2:= variation;
    best_day2 :=best_day;

elsif quarter=3 then
    v_q3 := v_q;
    q_range3 :=q_range;
    var3:= variation;
    best_day3 :=best_day;

else 
    v_q4 := v_q;
    q_range4 :=q_range;
    var4:= variation;
    best_day4 :=best_day;

end if;
end loop;
end GET_VALUES_Q;

----------------------PROCEDIMIETNO PARA INSERTAR VALORES-----------------------------
procedure insert_values_q(empresa in BOLSA_VALOR.COMPANY%TYPE,
                            v_q1 in number,q_range1 in varchar2,var1 in number,best_day1 in date,
                            v_q2 in number,q_range2 in varchar2,var2 in number,best_day2 in date,
                            v_q3 in number,q_range3 in varchar2,var3 in number,best_day3 in date,
                            v_q4 in number,q_range4 in varchar2,var4 in number,best_day4 in date,Q_best_mill in varchar2)
                            
is
best_dayq1 varchar2(30):=to_char(best_day1,'MON DD, YYYY','NLS_DATE_LANGUAGE = English');
best_dayq2 varchar2(30):=to_char(best_day2,'MON DD, YYYY','NLS_DATE_LANGUAGE = English');
best_dayq3 varchar2(30):=to_char(best_day3,'MON DD, YYYY','NLS_DATE_LANGUAGE = English');
best_dayq4 varchar2(30):=to_char(best_day4,'MON DD, YYYY','NLS_DATE_LANGUAGE = English');

begin 

INSERT INTO RESUME_Q_TABLE VALUES(empresa,v_q1,q_range1,var1,best_dayq1,
                                v_q2,q_range2,var2,best_dayq2,
                                v_q3,q_range3,var3,best_dayq3,
                                v_q4,q_range4,var4,best_dayq4,Q_best_mill);
end insert_values_q;


-----------------PROCEDIMIENTO PARA OBTENER EL RESUMEN DE LA BOLSA DE VALORES-----------
procedure resumen_bolsa(anio in number)
is
cursor company_cursor is select distinct company from bolsa_valor;
empresa varchar2(40);

v_q1  number;
q_range1 varchar2(30);
var1 number;
best_day1  date;

v_q2  number;
q_range2 varchar2(30);
var2 number;
best_day2  date;

v_q3  number;
q_range3 varchar2(30);
var3 number;
best_day3  date;

v_q4  number;
q_range4 varchar2(30);
var4 number;
best_day4  date;

Q_best_mill  varchar(30);

begin
--LIMPIA TABLA
EXECUTE IMMEDIATE 'TRUNCATE TABLE RESUME_Q_TABLE';
-----------
open company_cursor;
loop
fetch company_cursor into empresa;
 EXIT WHEN company_cursor%NOTFOUND;

get_values_q(empresa,anio,v_q1,q_range1,var1,best_day1,
                    v_q2,q_range2,var2,best_day2,
                    v_q3,q_range3,var3,best_day3,
                    v_q4,q_range4,var4,best_day4,Q_best_mill);

insert_values_q(empresa,v_q1,q_range1,var1,best_day1,
                        v_q2,q_range2,var2,best_day2,
                        v_q3,q_range3,var3,best_day3,
                        v_q4,q_range4,var4,best_day4,Q_best_mill);--insertar los valores a tabla
end loop;
close company_cursor;

end RESUMEN_BOLSA;


END BOLSA_VALORES;


--ejecucion---
execute BOLSA_VALORES.resumen_bolsa(2015);

select* from RESUME_Q_TABLE;
