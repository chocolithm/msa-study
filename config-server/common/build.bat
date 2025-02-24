@echo off
setlocal enabledelayedexpansion

:: 로그 파일 경로 설정
set LOG_FILE=C:\Users\kangy\git\msa\config-server\common\build_log.txt

:: 로그 초기화
echo Build started at %DATE% %TIME% > "%LOG_FILE%"
echo Build started at %DATE% %TIME%

:: Config Server 빌드
cd /d "C:\Users\kangy\git\msa\config-server"
echo Config Server: Maven 빌드 시작... >> "%LOG_FILE%" 2>&1
echo Config Server: Maven 빌드 시작...
cmd /c "mvn clean package -DskipTests" >> "%LOG_FILE%" 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Config Server 빌드 실패! 오류 메시지를 확인하세요. >> "%LOG_FILE%" 2>&1
    echo [ERROR] Config Server 빌드 실패!
    goto ERROR_HANDLER
)

echo Config Server: Docker 이미지 빌드... >> "%LOG_FILE%" 2>&1
echo Config Server: Docker 이미지 빌드...
docker build --build-arg JAR_FILE=target/configserver-0.0.1-SNAPSHOT.jar -t ostock/configserver:0.0.1-SNAPSHOT . >> "%LOG_FILE%" 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Config Server Docker 빌드 실패! >> "%LOG_FILE%" 2>&1
    echo [ERROR] Config Server Docker 빌드 실패!
    goto ERROR_HANDLER
)

echo Config Server 실행... >> "%LOG_FILE%" 2>&1
echo Config Server 실행...
start /b mvn spring-boot:run >nul 2>&1
timeout /t 10 /nobreak >nul

:: Eureka Server 빌드
cd /d "C:\Users\kangy\git\msa\eureka-server"
echo Eureka Server: Maven 빌드 시작... >> "%LOG_FILE%" 2>&1
echo Eureka Server: Maven 빌드 시작...
cmd /c "mvn clean package -DskipTests" >> "%LOG_FILE%" 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Eureka Server 빌드 실패! >> "%LOG_FILE%" 2>&1
    echo [ERROR] Eureka Server 빌드 실패!
    goto ERROR_HANDLER
)

echo Eureka Server: Docker 이미지 빌드... >> "%LOG_FILE%" 2>&1
echo Eureka Server: Docker 이미지 빌드...
docker build --build-arg JAR_FILE=target/eurekaserver-0.0.1-SNAPSHOT.jar -t ostock/eurekaserver:0.0.1-SNAPSHOT . >> "%LOG_FILE%" 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Eureka Server Docker 빌드 실패! >> "%LOG_FILE%" 2>&1
    echo [ERROR] Eureka Server Docker 빌드 실패!
    goto ERROR_HANDLER
)

echo Eureka Server 실행... >> "%LOG_FILE%" 2>&1
echo Eureka Server 실행...
start /b mvn spring-boot:run >nul 2>&1
timeout /t 10 /nobreak >nul

:: Gateway Server 빌드
cd /d "C:\Users\kangy\git\msa\gateway-server"
echo Gateway Server: Maven 빌드 시작... >> "%LOG_FILE%" 2>&1
echo Gateway Server: Maven 빌드 시작...
cmd /c "mvn clean package -DskipTests" >> "%LOG_FILE%" 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Gateway Server 빌드 실패! >> "%LOG_FILE%" 2>&1
    echo [ERROR] Gateway Server 빌드 실패!
    goto ERROR_HANDLER
)

echo Gateway Server: Docker 이미지 빌드... >> "%LOG_FILE%" 2>&1
echo Gateway Server: Docker 이미지 빌드...
docker build --build-arg JAR_FILE=target/gatewayserver-0.0.1-SNAPSHOT.jar -t ostock/gatewayserver:0.0.1-SNAPSHOT . >> "%LOG_FILE%" 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Gateway Server Docker 빌드 실패! >> "%LOG_FILE%" 2>&1
    echo [ERROR] Gateway Server Docker 빌드 실패!
    goto ERROR_HANDLER
)

:: Licensing Service 빌드
cd /d "C:\Users\kangy\git\msa\licensing-service"
echo Licensing Service: Maven 빌드 시작... >> "%LOG_FILE%" 2>&1
echo Licensing Service: Maven 빌드 시작...
cmd /c "mvn clean package -DskipTests" >> "%LOG_FILE%" 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Licensing Service 빌드 실패! >> "%LOG_FILE%" 2>&1
    echo [ERROR] Licensing Service 빌드 실패!
    goto ERROR_HANDLER
)

echo Licensing Service: Docker 이미지 빌드... >> "%LOG_FILE%" 2>&1
echo Licensing Service: Docker 이미지 빌드...
docker build --build-arg JAR_FILE=target/licensing-service-0.0.1-SNAPSHOT.jar -t ostock/licensing-service:0.0.1-SNAPSHOT . >> "%LOG_FILE%" 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Licensing Service Docker 빌드 실패! >> "%LOG_FILE%" 2>&1
    echo [ERROR] Licensing Service Docker 빌드 실패!
    goto ERROR_HANDLER
)

:: Organization Service 빌드
cd /d "C:\Users\kangy\git\msa\organization-service"
echo Organization Service: Maven 빌드 시작... >> "%LOG_FILE%" 2>&1
echo Organization Service: Maven 빌드 시작...
cmd /c "mvn clean package -DskipTests" >> "%LOG_FILE%" 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Organization Service 빌드 실패! >> "%LOG_FILE%" 2>&1
    echo [ERROR] Organization Service 빌드 실패!
    goto ERROR_HANDLER
)

echo Organization Service: Docker 이미지 빌드... >> "%LOG_FILE%" 2>&1
echo Organization Service: Docker 이미지 빌드...
docker build --build-arg JAR_FILE=target/organization-service-0.0.1-SNAPSHOT.jar -t ostock/organization-service:0.0.1-SNAPSHOT . >> "%LOG_FILE%" 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Organization Service Docker 빌드 실패! >> "%LOG_FILE%" 2>&1
    echo [ERROR] Organization Service Docker 빌드 실패!
    goto ERROR_HANDLER
)

goto CLEANUP

:ERROR_HANDLER
echo [ERROR] 오류 발생! 정리 작업을 수행합니다. >> "%LOG_FILE%" 2>&1

:CLEANUP
:: Eureka Server 종료
echo Eureka Server 종료... >> "%LOG_FILE%" 2>&1
echo Eureka Server 종료...

:: eurekaserver 실행 중인 프로세스를 찾아서 종료
for /f "tokens=2" %%i in ('tasklist ^| findstr "java"') do (
    wmic process where "processid=%%i" get commandline | findstr "eurekaserver" > nul
    if %errorlevel% equ 0 (
        echo Terminating process with PID %%i (eurekaserver)
        taskkill /f /pid %%i
    )
)

:: Config Server 종료
echo Config Server 종료... >> "%LOG_FILE%" 2>&1
echo Config Server 종료...

:: configserver가 실행 중인 프로세스를 찾아서 종료
for /f "tokens=2" %%i in ('tasklist ^| findstr "java"') do (
    wmic process where "processid=%%i" get commandline | findstr "configserver" > nul
    if %errorlevel% equ 0 (
        echo Terminating process with PID %%i (configserver)
        taskkill /f /pid %%i
    )
)

echo 모든 작업이 완료되었습니다. >> "%LOG_FILE%" 2>&1
echo 모든 작업이 완료되었습니다.