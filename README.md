# devops-04-Final-Team5
# 리소스 아키텍쳐
<img width="1882" alt="스크린샷 2023-06-28 06 47 00" src="https://github.com/cs-devops-bootcamp/devops-04-Final-Team5/assets/105037141/7818c955-8934-4d94-bacd-1ff8ffcebfda">

프로젝트 발표자료
https://docs.google.com/presentation/d/1A6nd_WcityqFIknwzVEpzRsgm7nvGPgxpVvEOD_bmxo/edit?usp=drive_link

# 기능 요구사항

작업의 진행상황을 체계적으로 관리할 수 있도록 업무를 분배하고 진행상황을 관리할 수 있는 시스템을 구축해야한다.

- 사용자는 개인 정보를 이용해 **로그인**을 할 수 있어야 한다.
- 사용자는 새로운 Task를 생성하고, 생성한 Task를 **수정하거나 삭제, 조회**할 수 있어야 한다.
- 사용자는 Task의 진행 상황을 **대기 중, 진행 중, 완료** 등으로 관리할 수 있어야 한다.
- 사용자는 새로운 Task가 추가되거나, 업무 상태가 변경될 때 사용자에게 **알림**을 보낼 수 있어야 한다.
- 특정 업무를 사용자에게 할당하고, 할당된 업무를 사용자가 확인할 수 있어야 한다.


# 필요한 리소스

- 백엔드 개발:  **JavaScript (Node.js)**
- 데이터베이스 관리:  **Amazon RDS (MySQL), DynamoDB**
- 알림 시스템: **Amazon EventBridge, SES**
- 컨테이너화: **Docker**
- CI/CD 파이프라인: **GitHub Actions**
- 모니터링: **CloudWatch 경보**


# 인프라 요구사항

- 사용되는 애플리케이션들은 컨테이너로 구동되어야합니다.
- 시스템 전반에 가용성, 내결함성, 확장성, 보안성이 고려된 서비스들이 포함되어야 합니다.
- 하나 이상의 컴퓨팅 유닛에 대한 CI/CD 파이프라인이 구성되어야합니다.
- 시스템 메트릭 또는 저장된 데이터에 대한 하나 이상의 시각화된 모니터링 시스템이 구축되어야합니다.


이 프로그램은 다수의 인원이 한 작업에 대해 역할을 나누어 프로젝트를 진행해야 할 때 이용할 수 있습니다. 사용자는 어떠한 내용의 Task를 생성할 수 있고, 특정 작업에 대한 담당자(가입되어 있는 사용자)를 지정합니다. 담당자는 그 작업을 진행하고, 담당자는 진행 상황이 바뀔 시 Task의 진행도를 바꿀 수 있고 진행도 혹은 Task 의 내용이 수정될 때마다 사용자에게 메일로 특정 로그 내용을 전송하여 보다 쉽게 수정된 내용을 확인할 수 있도록 합니다.

<br>

#  CRUD API 명세

[API](https://docs.google.com/spreadsheets/d/16TmUODKyEjoQWa39oxZd9cOC5y3H_j9pezJz9fYgPGI/edit#gid=0)

URL | Method | Function | Req | Res
-- | -- | -- | -- | --
/api/sign_in | GET | 로그인 요청 | { "email": "(email)", "password": "(password)" } | { "message": "사용자가 성공적으로 로그인했습니다.", "email": "(email)"}
/api/tasks | POST | 작업 추가 | { "Task_name": "(Task_name)", "Task_contents": "(Task_contents)", "Task_status": "(Task_status)", "Deadline": "(Deadline)", "PIC": "(PIC)", "Supervisor": "(Supervisor)" } | { "message": "작업이 성공적으로 생성되었습니다.", "Task_id": "(Task_id)" }
/api/tasks/(task_id) | PUT | 특정 작업 수정 | { "Task_contents": "(Task_contents)", "Task_status": "(Task_status)", "Deadline": "(Deadline)", "PIC": "(PIC)" } | { "message": "작업이 성공적으로 업데이트되었습니다." }
/api/tasks/(task_id) | DELETE | 특정 작업 삭제 | { "Task_id": "(Task_id)" } | { "message": "작업이 성공적으로 삭제되었습니다" ,"Task_id": "(Task_id)", "Task_name": "(Task_name)"}
/api/tasks | GET | 전체 작업 조회 |   | { "message": "전체 작업 조회" }

<br>

### **1. 코드 수정 및 Image Push**
---
 Git Action은 GitHub 레포지토리의 코드가 수정될 때마다 빌드를 트리거해서 자동으로 각 코드들이 배포되어야할 리소스로 배포합니다. 구현한 CRUD 이미지는 Git Action이 자동으로 만들어둔 ECR(Elastic Container Registry)에 이미지를 Push합니다. 또한, Push된 이미지를 지정한 ECS의 서비스 내에 작업을 생성합니다. <br>
 뿐만 아니라 로그인요청 처리코드와 로그이벤트 처리코드는 각각의 람다 함수로, 프론트 웹페이지 코드는 s3 버킷으로 배포됩니다.

<br>

### **2. S3를 사용한 정적 호스팅** 
---

- **Route 53**을 통해 기록된 도메인은 S3의 정적 호스팅 사이트에 연결
  - 도메인에 액세스하면 정적 사이트와 상호 작용
  - S3 버킷 내부에는 객체로 Login 페이지와 Task 페이지가 있고, 도메인에 액세스를 하면 Login 페이지와 연결되어 로그인 시 Task 페이지로 넘어간다. 
  - 로그인 된 사용자가 사이트의 주소로 특정 CRUD 요청을 보내면 DB 서버에서 데이터를 가져와서 HTML 테이블에 동적으로 데이터를 추가한다.



<br>

### **3. 사용자 인증 과정** 
---

 API Gateway를 Lambda의 트리거로 연결하여 API 요청을 수신하고 이러한 요청에 대한 정보를 처리를 위해 해당 Lambda 함수에 전달합니다. Lambda + DynamoDB는 인증 계층 역할을 하며, 사용자가 로그인에 성공 시 로그인 요청을 수신하고 자격 증명을 확인하며 해당 데이터를 DynamoDB에 저장하여 성공적인 로그인을 나타냅니다. 잘못된 자격 증명 또는 기타 인증 문제로 인해 사용자가 로그인에 실패하면 Lambda 함수가 요청을 처리하고 인증 실패를 기록합니다. 이 경우 로그인 시도 실패를 나타내므로 데이터가 DynamoDB에 누적되지 않습니다.

<br>

### **4. ALB 및 ASG** 
---

 사용자 요청은 특정 Virtual Private Cloud(VPC) 경계의 ALB(Application Load Balancer)를 통해 ASG(Auto Scaling Group)에 들어갑니다. ASG는 Public Subnet 내에 위치해 있으며, ASG가 관리하는 EC2 인스턴스 내부에서 배포한 이미지가 실행된다. 인스턴스는 들어오는 요청을 처리하고 CRUD 작업을 실행하며, RDS에 그 내용을 저장합니다.

**Fargate가 아닌 EC2를 사용한 이유**

- Fargate는 서버리스로 구동이 되고, 리소스 사용률이 높을수록 비용 방면에서 효율이 좋다. 하지만, ECS의 컨테이너를 구동할 때 사용하는 컴퓨팅 유닛으로 EC2를 사용하는 것이 리소스 사용률이 낮을 경우에는 Fargate가 EC2보다 평균적으로 비용이 13~18% 정도 비싸고, Cloudwatch를 통해서 리소스 예약률을 90% 이상 높게 유지하도록 auto scaling을 하도록 만들면 더 비용 절감을 할 수 있다.

- ASG(EC2)를 이용할 경우 인프라 관리가 어렵고 운영이 복잡할 수 있지만, 비용 방면을 고려하여 EC2를 사용하기로 결정하였다.

<br>

### **5. DynamoDB Log** 
---

 사용자의 요청에 따른 결과 및 로그를 모두 Log DynamoDB에 저장하게 되고, DynamoDB에 로그가 쌓일 때마다 EventBridge에서 로그를 설정해둔 Rule에 따라 필터링되어 Lambda를 통해 로그가 사용자에게 SES로 전송됩니다. 

**로그 저장소로 DynamoDB를 사용한 이유**

- 이벤트 로그 저장소 DB는 작업 변경 로그 메시지를 저장하는 것이 목적이기 때문에 매번 상황에 따라 형식과 내용이 바뀐다. 

- DynamoDB는 데이터가 key-value 형태로 저장되기 때문에 속성의 변경과 추가가 자유롭고 로그 메시지를 유동적으로 저장하기 용이하며, read 속도도 빨라 접속이 많이 발생해도 견딜 수 있다. 

- 구현한 아키텍처는 적은 양의 로그 데이터를 처리하기 때문에 처리 속도가 빠른 DynamoDB가 효과적일 것이라고 생각했다. 

- DynamoDB는 AWS Lambda와 같은 이벤트 기반 처리 시스템과 잘 통합되어 실시간 로그 분석과 같은 복잡한 로그 처리 작업 또한 쉽게 구현할 수 있다.

## Hoonology.click
<img width="1589" alt="KakaoTalk_20230628_110238378" src="https://github.com/cs-devops-bootcamp/devops-04-Final-Team5/assets/58872932/42582658-cb2a-4074-bf6d-6a8d23a46d99">
<img width="1589" alt="KakaoTalk_20230628_110238378_01" src="https://github.com/cs-devops-bootcamp/devops-04-Final-Team5/assets/58872932/e17b7e98-33ef-40de-8033-5af799f11fc2">
<img width="1589" alt="KakaoTalk_20230628_110238378_02" src="https://github.com/cs-devops-bootcamp/devops-04-Final-Team5/assets/58872932/d0cafc11-1315-429d-b555-9019acd4ea4c">
로그인으로 사용자 인증을 통해 DB에서 Task의 현황을 가져온다.

<br>
