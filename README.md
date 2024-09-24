samsung sdk 추가
ubuntu 권한 공유

/*AWS 계정 권한 확인
먼저 팀원이 AWS에서 **IAM(Identity and Access Management)**을 사용해 당신에게 해당 인스턴스에 대한 권한을 부여했는지 확인해야 합니다.
권한이 없으면 인스턴스를 수정할 수 없으므로, 팀원에게 EC2 인스턴스에 대한 접근 권한을 요청해야 합니다. 필요한 권한은 주로 EC2 인스턴스의 수정, 삭제, 접속 권한입니다.
2. IAM을 통한 권한 공유
팀원은 AWS 콘솔에서 IAM 역할을 설정하고, 당신을 추가하여 EC2 관리 권한을 부여할 수 있습니다. 필요한 권한은 AmazonEC2FullAccess나 특정 인스턴스에 대한 액세스 권한입니다.
단계:
팀원이 AWS Management Console에서 IAM을 선택합니다.
Users 항목에서 당신을 추가하거나, 이미 추가되어 있다면 적절한 권한을 부여합니다.
EC2 관리 권한을 가진 정책을 할당합니다. 예를 들어, AmazonEC2FullAccess 같은 권한을 추가합니다.
권한이 부여되면, 당신은 해당 EC2 인스턴스를 수정하거나 재설정할 수 있습니다.*/

/*
Ubuntu 서버로 전환하려면 현재 팀원이 생성한 Windows 서버 대신 Ubuntu 서버를 새로 생성하거나, 기존 Windows 인스턴스를 종료하고 Ubuntu 인스턴스로 교체해야 합니다. 다음은 AWS에서 Ubuntu 서버를 설정하는 방법입니다.

1. Ubuntu 서버 인스턴스 생성
AWS Management Console에 접속합니다.
EC2(Elastic Compute Cloud) 대시보드로 이동합니다.
"Launch Instance" 버튼을 클릭하여 새 인스턴스를 만듭니다.
단계별 설정:
AMI 선택:
Ubuntu Server 22.04 LTS 또는 Ubuntu Server 20.04 LTS를 선택합니다. LTS(Long Term Support) 버전은 장기적인 안정성과 지원을 제공합니다.
인스턴스 유형 선택:
일반적인 개발/테스트 용도로는 t2.micro 인스턴스가 무료로 제공됩니다. 요구에 맞는 인스턴스 유형을 선택합니다.
키 페어 생성:
SSH로 서버에 접속하기 위해 키 페어를 생성하거나, 기존 키 페어를 사용합니다. 키 파일(.pem)을 안전한 위치에 저장합니다.
네트워크 설정:
기본적으로 자동으로 설정되지만, 보안 그룹에서 **SSH(22번 포트)**가 열려 있는지 확인해야 합니다. 이 포트를 통해 서버에 접속할 수 있습니다.
스토리지 설정:
기본 디스크 크기(보통 8GB)를 그대로 두거나 필요에 따라 조정합니다.
인스턴스 실행:
설정을 완료한 후 "Launch" 버튼을 클릭해 인스턴스를 실행합니다.






타 계정 캐릭터를 볼 수 있게 끔 하도록 하겠음
