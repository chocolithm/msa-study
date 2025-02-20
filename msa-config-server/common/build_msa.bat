@echo off
setlocal enabledelayedexpansion

:: 로그 파일 경로 설정
set LOG_FILE=C:\Users\kangy\git\msa\msa-config-server\common\build_log.txt

:: 로그 초기화
echo Build started at %DATE% %TIME% > "%LOG_FILE%"
echo Build started at %DATE% %TIME%

:: 1. Config Server 빌드
cd /d "C:\Users\kangy\git\msa\msa-config-server"
echo [1] Config Server: Maven 빌드 시작... >> "%LOG_FILE%" 2>&1
echo [1] Config Server: Maven 빌드 시작...
cmd /c "mvn clean package -DskipTests" >> "%LOG_FILE%" 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Config Server 빌드 실패! 오류 메시지를 확인하세요. >> "%LOG_FILE%" 2>&1
    echo [ERROR] Config Server 빌드 실패!
    pause
    exit /b %ERRORLEVEL%
)

echo [2] Config Server: Docker 이미지 빌드... >> "%LOG_FILE%" 2>&1
echo [2] Config Server: Docker 이미지 빌드...
docker build --build-arg JAR_FILE=target/configserver-0.0.1-SNAPSHOT.jar -t ostock/configserver:0.0.1-SNAPSHOT . >> "%LOG_FILE%" 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Config Server Docker 빌드 실패! >> "%LOG_FILE%" 2>&1
    echo [ERROR] Config Server Docker 빌드 실패!
    pause
    exit /b %ERRORLEVEL%
)

echo [3] Config Server 실행... >> "%LOG_FILE%" 2>&1
echo [3] Config Server 실행...
start "Config Server" mvn spring-boot:run
timeout /t 20 /nobreak >nul

:: 2. Eureka Server 빌드
cd /d "C:\Users\kangy\git\msa\msa-eureka-server"
echo [4] Eureka Server: Maven 빌드 시작... >> "%LOG_FILE%" 2>&1
echo [4] Eureka Server: Maven 빌드 시작...
cmd /c "mvn clean package -DskipTests" >> "%LOG_FILE%" 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Eureka Server 빌드 실패! >> "%LOG_FILE%" 2>&1
    echo [ERROR] Eureka Server 빌드 실패!
    pause
    exit /b %ERRORLEVEL%
)

echo [5] Eureka Server: Docker 이미지 빌드... >> "%LOG_FILE%" 2>&1
echo [5] Eureka Server: Docker 이미지 빌드...
docker build --build-arg JAR_FILE=target/eurekaserver-0.0.1-SNAPSHOT.jar -t ostock/eurekaserver:0.0.1-SNAPSHOT . >> "%LOG_FILE%" 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Eureka Server Docker 빌드 실패! >> "%LOG_FILE%" 2>&1
    echo [ERROR] Eureka Server Docker 빌드 실패!
    pause
    exit /b %ERRORLEVEL%
)

:: 3. Licensing Service 빌드
cd /d "C:\Users\kangy\git\msa\msa-licensing-service"
echo [6] Licensing Service: Maven 빌드 시작... >> "%LOG_FILE%" 2>&1
echo [6] Licensing Service: Maven 빌드 시작...
cmd /c "mvn clean package -DskipTests" >> "%LOG_FILE%" 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Licensing Service 빌드 실패! >> "%LOG_FILE%" 2>&1
    echo [ERROR] Licensing Service 빌드 실패!
    pause
    exit /b %ERRORLEVEL%
)

echo [7] Licensing Service: Docker 이미지 빌드... >> "%LOG_FILE%" 2>&1
echo [7] Licensing Service: Docker 이미지 빌드...
docker build --build-arg JAR_FILE=target/licensing-service-0.0.1-SNAPSHOT.jar -t ostock/licensing-service:0.0.1-SNAPSHOT . >> "%LOG_FILE%" 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Licensing Service Docker 빌드 실패! >> "%LOG_FILE%" 2>&1
    echo [ERROR] Licensing Service Docker 빌드 실패!
    pause
    exit /b %ERRORLEVEL%
)

:: 4. Config Server 종료
echo [8] Config Server 종료... >> "%LOG_FILE%" 2>&1
echo [8] Config Server 종료...

:: configserver가 실행 중인 프로세스를 찾아서 종료
for /f "tokens=2" %%i in ('tasklist ^| findstr "java"') do (
    wmic process where "processid=%%i" get commandline | findstr "configserver" > nul
    if %errorlevel% equ 0 (
        echo Terminating process with PID %%i (configserver)
        taskkill /f /pid %%i
    )
)

echo [✔] 모든 작업이 완료되었습니다. >> "%LOG_FILE%" 2>&1
echo [✔] 모든 작업이 완료되었습니다.
pause
exit /b 0