<#
  Dev seed script for Sports Hub v2 (Windows PowerShell)
  - Creates sample accounts (Auth)
  - Creates sample profiles (User)
  - Creates sample teams, memberships, notices (Team)
  - Creates sample recruit posts and applications (Recruit)
  - Creates sample notifications (Notification)

  Prereqs:
  - Run docker compose first: cd sports-hub-v2/infra/docker; docker compose up -d --build
  - Ensure services listen on 8081~8085 as in compose
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

Write-Host '== Seeding: Accounts (auth) ==' -ForegroundColor Cyan
$u1   = TryGet "$AuthBase/api/auth/accounts?email=user1@example.com"
if (-not $u1)   { $u1   = PostJson "$AuthBase/api/auth/accounts" @{ email='user1@example.com';   password='Secret123!';  role='USER'  } }
$capt = TryGet "$AuthBase/api/auth/accounts?email=captain@example.com"
if (-not $capt) { $capt = PostJson "$AuthBase/api/auth/accounts" @{ email='captain@example.com'; password='Captain123!'; role='USER'  } }
$admin= TryGet "$AuthBase/api/auth/accounts?email=admin@example.com"
if (-not $admin){ $admin= PostJson "$AuthBase/api/auth/accounts" @{ email='admin@example.com';   password='Admin123!';   role='ADMIN' } }

Write-Host '== Seeding: Profiles (user) ==' -ForegroundColor Cyan
function EnsureProfile($accountId, $name, $region, $position, $phone) {
  $p = TryGet "$UserBase/api/users/profiles/by-account/$accountId"
  if (-not $p) {
    $p = PostJson "$UserBase/api/users/profiles" @{ accountId=$accountId; name=$name; region=$region; preferredPosition=$position; phoneNumber=$phone }
  }
  return $p
}
$p1    = EnsureProfile $u1.id    'User One'    'Seoul'    'MF' '010-1000-1000'
$pcap  = EnsureProfile $capt.id  'Captain Kim' 'Gyeonggi' 'DF' '010-2000-2000'
$padmin= EnsureProfile $admin.id 'Admin Lee'   'Seoul'    'GK' '010-3000-3000'

Write-Host '== Seeding: Teams (team) ==' -ForegroundColor Cyan
function EnsureTeam($name, $captainProfileId, $region) {
  $list = TryGet "$TeamBase/api/teams?region=$([uri]::EscapeDataString($region))"
  $existing = $null
  if ($list) { $existing = $list | Where-Object { $_.teamName -eq $name } }
  # backend-team CreateRequest requires non-blank 'name'; it also accepts 'teamName'
  # Send both for compatibility with current DTO/validation
  if (-not $existing) { return PostJson "$TeamBase/api/teams" @{ name=$name; teamName=$name; captainProfileId=$captainProfileId; region=$region } }
  return $existing[0]
}
$t1 = EnsureTeam 'Seoul FC'         $pcap.id 'Seoul'
$t2 = EnsureTeam 'Gyeonggi United'  $pcap.id 'Gyeonggi'

Write-Host '== Seeding: Memberships (team) ==' -ForegroundColor Cyan
PostJson "$TeamBase/api/teams/$($t1.id)/members" @{ profileId=$p1.id;   roleInTeam='PLAYER' }  | Out-Null
PostJson "$TeamBase/api/teams/$($t1.id)/members" @{ profileId=$pcap.id; roleInTeam='CAPTAIN' } | Out-Null

Write-Host '== Seeding: Notices (team) ==' -ForegroundColor Cyan
PostJson "$TeamBase/api/teams/$($t1.id)/notices" @{ title='Team Notice'; content='Practice this Saturday 10:00'; } | Out-Null

Write-Host '== Seeding: Recruit posts (recruit) ==' -ForegroundColor Cyan
$post1 = PostJson "$RecruitBase/api/recruit/posts" @{ teamId=$t1.id; writerProfileId=$pcap.id; title='Scrim Mercenary Wanted'; content='Friendly scrim, afternoon ~2h'; region='Seoul';   category='MERCENARY'; targetType='USER'; status='RECRUITING' }
$post2 = PostJson "$RecruitBase/api/recruit/posts" @{ teamId=$t1.id; writerProfileId=$pcap.id; title='Weekend Match Team Wanted';  content='Friendly match';                     region='Gyeonggi'; category='MATCH';     targetType='TEAM'; status='RECRUITING' }
# TEAM recruitment: team recruiting players
$post3 = PostJson "$RecruitBase/api/recruit/posts" @{ teamId=$t1.id; writerProfileId=$pcap.id; title='Looking for Team Members';    content='Join our team! Weekly practice.';    region='Seoul';   category='TEAM';       targetType='USER'; status='RECRUITING' }

Write-Host '== Seeding: Applications (recruit) ==' -ForegroundColor Cyan
PostJson "$RecruitBase/api/recruit/posts/$($post1.id)/applications" @{ applicantProfileId=$p1.id; description='I can play MF'; status='PENDING' } | Out-Null

Write-Host '== Seeding: Notifications (notification) ==' -ForegroundColor Cyan
PostJson "$NotifBase/api/notifications" @{ receiverProfileId=$p1.id;   type='WELCOME';     message='Welcome to Sports Hub!' }              | Out-Null
PostJson "$NotifBase/api/notifications" @{ receiverProfileId=$pcap.id; type='APPLICATION'; message='Your application has been received.' } | Out-Null

Write-Host '== Done ==' -ForegroundColor Green
