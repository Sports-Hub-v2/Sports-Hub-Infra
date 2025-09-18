<#
  Dev seed script (Korean dataset) for Sports Hub v2
  - PowerShell 7(pwsh)에서 UTF-8 한글 문자열로 안전하게 동작합니다.
  - 생성 대상: 계정/프로필/팀/공지/모집글(TEAM/MATCH/MERCENARY)/지원/알림
#>

param(
  [string]$AuthBase    = 'http://localhost:8081',
  [string]$UserBase    = 'http://localhost:8082',
  [string]$TeamBase    = 'http://localhost:8083',
  [string]$RecruitBase = 'http://localhost:8084',
  [string]$NotifBase   = 'http://localhost:8085'
)

function PostJson($url, $body) {
  $json = $body | ConvertTo-Json -Depth 6
  return Invoke-RestMethod -Method Post -Uri $url -ContentType 'application/json' -Body $json
}

function TryGet($url) {
  try { return Invoke-RestMethod -Method Get -Uri $url } catch { return $null }
}

Write-Host '== 시드: 계정(auth) ==' -ForegroundColor Cyan
$u1   = TryGet "$AuthBase/api/auth/accounts?email=user1@example.com"
if (-not $u1)   { $u1   = PostJson "$AuthBase/api/auth/accounts" @{ email='user1@example.com';   password='Secret123!';  role='USER'  } }
$capt = TryGet "$AuthBase/api/auth/accounts?email=captain@example.com"
if (-not $capt) { $capt = PostJson "$AuthBase/api/auth/accounts" @{ email='captain@example.com'; password='Captain123!'; role='USER'  } }
$admin= TryGet "$AuthBase/api/auth/accounts?email=admin@example.com"
if (-not $admin){ $admin= PostJson "$AuthBase/api/auth/accounts" @{ email='admin@example.com';   password='Admin123!';   role='ADMIN' } }

Write-Host '== 시드: 프로필(user) ==' -ForegroundColor Cyan
function EnsureProfile($accountId, $name, $region, $position, $phone) {
  $p = TryGet "$UserBase/api/users/profiles/by-account/$accountId"
  if (-not $p) {
    $p = PostJson "$UserBase/api/users/profiles" @{ accountId=$accountId; name=$name; region=$region; preferredPosition=$position; phoneNumber=$phone }
  }
  return $p
}
$p1    = EnsureProfile $u1.id    '사용자 홍길동'     '서울'   'MF' '010-1000-1000'
$pcap  = EnsureProfile $capt.id  '캡틴 김철수'       '경기'   'DF' '010-2000-2000'
$padmin= EnsureProfile $admin.id '관리자 이관리'     '서울'   'GK' '010-3000-3000'

Write-Host '== 시드: 팀(team) ==' -ForegroundColor Cyan
function EnsureTeam($name, $captainProfileId, $region) {
  $list = TryGet "$TeamBase/api/teams?region=$([uri]::EscapeDataString($region))"
  $existing = $null
  if ($list) { $existing = $list | Where-Object { $_.teamName -eq $name } }
  if (-not $existing) { return PostJson "$TeamBase/api/teams" @{ teamName=$name; captainProfileId=$captainProfileId; region=$region } }
  return $existing[0]
}
$t1 = EnsureTeam '강남 유나이티드' $pcap.id '서울'
$t2 = EnsureTeam '홍대 풋볼클럽'   $pcap.id '서울'

Write-Host '== 시드: 팀 멤버십 ==' -ForegroundColor Cyan
PostJson "$TeamBase/api/teams/$($t1.id)/members" @{ profileId=$p1.id;   roleInTeam='PLAYER' }  | Out-Null
PostJson "$TeamBase/api/teams/$($t1.id)/members" @{ profileId=$pcap.id; roleInTeam='CAPTAIN' } | Out-Null

Write-Host '== 시드: 팀 공지 ==' -ForegroundColor Cyan
PostJson "$TeamBase/api/teams/$($t1.id)/notices" @{ title='주간 공지'; content='토요일 오전 10시 강남구민체육센터에서 연습합니다.' } | Out-Null

Write-Host '== 시드: 모집글(recruit) TEAM/MATCH/MERCENARY ==' -ForegroundColor Cyan
# TEAM: 팀원 모집(개인 대상)
$teamPost = PostJson "$RecruitBase/api/recruit/posts" @{
  teamId=$t1.id; writerProfileId=$pcap.id; title='수비수 2명 팀원 모집 (홍대)';
  content='수비 보강을 위해 팀원을 모집합니다. 매주 토/일 오전 활동.'; region='서울'; category='TEAM'; targetType='USER'; status='OPEN'
}
# MATCH: 경기 상대팀 모집(팀 대상)
$matchPost = PostJson "$RecruitBase/api/recruit/posts" @{
  teamId=$t1.id; writerProfileId=$pcap.id; title='주말 친선 경기 상대팀 모집 (용산)';
  content='일요일 오후 2시, 용산 실내 풋살장에서 친선 경기 희망.'; region='서울'; category='MATCH'; targetType='TEAM'; status='OPEN'
}
# MERCENARY: 용병 모집(개인 대상)
$mercPost = PostJson "$RecruitBase/api/recruit/posts" @{
  teamId=$t1.id; writerProfileId=$pcap.id; title='평일 오전 용병 구합니다 (강남)';
  content='목요일 오전 7시, 강남역 인근 풋살장. 미드필더 우대.'; region='서울'; category='MERCENARY'; targetType='USER'; status='OPEN'
}

Write-Host '== 시드: 신청(recruit applications) ==' -ForegroundColor Cyan
PostJson "$RecruitBase/api/recruit/posts/$($mercPost.id)/applications" @{ applicantProfileId=$p1.id; description='미드필더 가능합니다.'; status='PENDING' } | Out-Null

Write-Host '== 시드: 알림(notification) ==' -ForegroundColor Cyan
PostJson "$NotifBase/api/notifications" @{ receiverProfileId=$p1.id;   type='WELCOME';     message='스포츠허브에 오신 것을 환영합니다!' } | Out-Null
PostJson "$NotifBase/api/notifications" @{ receiverProfileId=$pcap.id; type='APPLICATION'; message='새로운 신청이 접수되었습니다.' } | Out-Null

Write-Host '== 완료 ==' -ForegroundColor Green

