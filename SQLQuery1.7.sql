/*Write a procedure that accept Staff_Code and updates the salary and store the old 
salary details in Staff_Master_Back (Staff_Master_Back has the same structure without any constraint) table. 
The procedure should return the updated salary as the return value
Exp< 2 then no Update
Exp>= 2 and <= 5 then 20% of salary
Exp> 5 then 25% of salary*/
SELECT * INTO Staff_Master_Back FROM (SELECT * FROM Staff_Master) AS Staff_Master_Back;

GO
CREATE PROCEDURE SalaryUpdate
@Staff_code numeric(8,0)
AS 
BEGIN
DECLARE @exp AS INT; 
SET @exp = (SELECT DATEDIFF(year, Hiredate,'2007/08/25')
FROM Staff_Master WHERE Staff_Code = @Staff_code);
IF @exp >=2 AND @exp <=5
BEGIN
UPDATE Staff_Master SET Salary = Salary + 0.2*Salary 
WHERE Staff_Code=@Staff_code
SELECT Staff_code, Staff_Name, Salary FROM Staff_Master WHERE Staff_Code=@Staff_code
END
ELSE IF @exp> 5
BEGIN
UPDATE Staff_Master SET Salary = Salary + 0.25*Salary 
WHERE Staff_Code=@Staff_code
SELECT Staff_code, Staff_Name, Salary FROM Staff_Master WHERE Staff_Code=@Staff_code
END
ELSE
SELECT Staff_code, Staff_Name, Salary FROM Staff_Master WHERE Staff_Code=@Staff_code
END

GO
SalaryUpdate 100001;


SELECT * FROM Staff_Master_Back;
SELECT * FROM Staff_Master;

/*Write a procedure to insert details into Book_Transaction table. 
Procedure should 2.accept the book code and staff/student code. 
Date of issue is current date and the expected return date should be 10 days from the current date. 
If the expected return date falls on Saturday or Sunday, then it should be the next working day. 
Suitable exceptions should be handled.*/
SELECT * FROM Book_Transaction;

GO
CREATE PROC InsertBook
@Book_code numeric(10,0),
@Stud_code numeric(6,0),
@Staff_code numeric(8,0)
AS
BEGIN
DECLARE @day AS varchar(10)
DECLARE @return_date AS datetime
SET @day = DATENAME(day,GETDATE()+10);
IF @day = 'Saturday'
SET @return_date = GETDATE()+12;
ELSE IF  @day = 'Sunday'
SET @return_date = GETDATE()+11;
ELSE
SET @return_date = GETDATE()+10;
BEGIN TRY
INSERT INTO Book_Transaction VALUES (@Book_code,@Stud_code,@Staff_code,GETDATE(),@return_date,@return_date)
END TRY
BEGIN CATCH
SELECT ERROR_MESSAGE();
END CATCH
END

GO
InsertBook 10000010,NULL,100008;

--Modify question 1 and display the results by specifying With result sets
exec SalaryUpdate 100001
with result sets((Staff_code INT, Staff_Name VARCHAR, Salary INT))

/*Create a procedure that accepts the book code as parameter from the user. 
Display the details of the students/staff that have borrowed that book and has not returned the same. 
The following details should be displayed
Student/StaffCode Student/StaffName IssueDate Designation ExpectedRet_Date*/

GO
CREATE PROCEDURE Borrowed
@Book_code NUMERIC(10,0)
AS
BEGIN
SELECT b.Stud_code, b.Staff_code, Stud_Name,Staff_Name, Issue_date, Des_Code, Exp_Return_date
FROM Student_master s JOIN Book_Transaction b
ON b.Stud_code= s.Stud_Code JOIN Staff_Master staff
ON b.Staff_code = staff.Staff_Code
WHERE Book_code=10000007 --AND Actual_Return_date IS NULL
END

GO
Borrowed 10000007

SELECT * FROM Book_Transaction WHERE Book_code=10000007;

SELECT b.Stud_code, b.Staff_code,Staff_Name, Issue_date, Des_Code, Exp_Return_date
FROM Student_master s JOIN Book_Transaction b 
ON b.Stud_code= s.Stud_Code JOIN Staff_Master sta
ON b.Staff_code = sta.Staff_Code
/*JOIN Student_master s
ON b.Stud_code= s.Stud_Code*/
WHERE Book_code=10000007

/*Write a procedure to update the marks details in the Student_marks table. The 5.following is the logic.
The procedure should accept student code , and marks as input parameter
Year should be the current year.
Student code cannot be null, but marks can be null.
Student code should exist in the student master.
The entering record should be unique ,i.e. no previous record should exist Suitable exceptions should be raised and procedure should return -1.
IF the data is correct, it should be added in the Student marks table and a success value of 0 should be returned.*/
SELECT * FROM Student_Marks;
SELECT * FROM Student_master;

GO 
ALTER PROC Marks
@Stud_code NUMERIC(6,0),
@Subject1 NUMERIC(3,0),
@Subject2 NUMERIC(3,0),
@Subject3 NUMERIC(3,0),
@return INT OUT
AS
BEGIN
IF(@Stud_code IS NULL)
	BEGIN
	RAISERROR('Stud_code cannot be null', 1, 1);
	
	SET @return = -1;
	END
ELSE IF NOT EXISTS(SELECT Stud_code FROM Student_master WHERE Stud_Code=@Stud_code)
	 BEGIN
	RAISERROR('Student code should exist in the student master.', 1, 1)
	PRINT 'Stud_code not present';
	SET @return = -1;
	END
ELSE IF((SELECT Stud_year FROM Student_Marks WHERE Stud_Code=@Stud_code) <> 2007)
	BEGIN
	RAISERROR('Year should be the current year.', 1, 1)
	END
ELSE
	BEGIN
	UPDATE Student_Marks 
	SET Subject1=@Subject1, Subject2 =@Subject2, Subject3=@Subject3
	WHERE Stud_Code=@Stud_code
	SET @return = 0;
	END
END

GO
DECLARE @result INT
EXEC Marks 1050,99,99,99,@result OUT; 
SELECT @result AS Success;

