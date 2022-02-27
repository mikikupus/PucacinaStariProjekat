#-------------------------------------------------------------------------------
extends KinematicBody
#VARIABLE KOJIMA MOZE DA SE PRISTUPA*-------------------------------------------
export var walkspeed = 10 #brzina normalnog kretanja
export var jump = 20 #jacina skoka
export var crouchspeed = 5
export var runspeed = 30 #brzina trcanja
export var gravity = -50 #gravitacija
export var sens = 0.001 #senzitiviti
#OBJEKTI------------------------------------------------------------------------
onready var metak = preload("res://Scene/Metak.tscn") #metak
onready var particle = preload("res://Scene/ParticlesPucanj.tscn")
onready var pivot = $pivot #pivot
onready var camera = $pivot/Camera #glavnakamera
onready var guncam = $pivot/Camera/ViewportContainer/Viewport/Guncam #kamera pistolja
onready var anim_player = $AnimationPlayer #animationplayer
onready var ray_cast = $pivot/Camera/RayCast #raycast
onready var ispucaj = $pivot/Camera/Hand/Primary/ispucaj #mesto odakle se ispucava metak
onready var primarygun = $pivot/Camera/Hand/Primary #definise se primarna puska
onready var secondarygun = $pivot/Camera/Hand/Secondary #definise se sekundarna puska
#POCETNO DEFINISANE-------------------------------------------------------------
var speed = walkspeed #definisanje brzine
var current_weapon = 1 #definise se da je trenutna puska primarna
#VEKTORI------------------------------------------------------------------------
var dir = Vector3.ZERO #pravac se definise kao vektor3 
var velocity = Vector3.ZERO #velocity se definise kao vektor3
var crouch_height = Vector3(0.7,0.5,0.7)
var default_height = Vector3(0.7,1,0.7)
#TRENUTNO PRAZNE----------------------------------------------------------------
var primary_current_ammo #municija primarne puske
var secondary_current_ammo #municija sekundarne puske
var bulletbas #promenljiva koja ce postati basis metka
var bullet #promenljiva koja ce postati metak
#BOOL---------------------------------------------------------------------------
var play = true #ako je igrivo
var can_fire = true #definise se da li moze da puca
var can_switch = true #definise se dali mzoe da menja oruzije
var can_run = true #definise da li moze da skace
var reloading = false #definise se da li reloaduje
#-------------------------------------------------------------------------------
func _ready(): #kada se igra pokrene
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) #Sakriva se strelica
	primary_current_ammo = primarygun.broj_metaka #definise se na pocetku da je broj metaka primarne puske jednak broju metaka sekundarne puske
	secondary_current_ammo = secondarygun.broj_metaka #definise se na pocetku da je broj metaka sekundarne puske jednak broju metaka sekundarne puske
#-------------------------------------------------------------------------------
func weapon_select(): #bira se koja je puska selektovana
	if Input.is_action_just_pressed("primary") and can_switch: #ako se klikne broj 1
		#anim_player.play("PrimaryPucanje")
		current_weapon = 1 #trenutna puska je primarna
		ispucaj = $pivot/Camera/Hand/Primary/ispucaj #postavlja se da je mesto ispucaja mesto ispucaja od primarne puske
		#yield(get_tree().create_timer(0.5),"timeout") 

	if Input.is_action_just_pressed("secondary") and can_switch: #ako se klikne broj 2
		current_weapon = 2 #trenutna puska je sekundarna
		ispucaj = $pivot/Camera/Hand/Secondary/ispucaj #postavlja se da je mesto ispucaja mesto ispucaja od sekundarne puske
	#---------------------------------------------------------------------------
	if current_weapon == 1: #ako je puska primarna
		primarygun.visible = true #primarna puska je vidljiva
	else: #u svakom drugom slucaju
		primarygun.visible = false #primarna puska je nevidljiva
	#---------------------------------------------------------------------------
	if current_weapon == 2: #ako je puska sekundarna
		secondarygun.visible = true #sekundarna puska je vidljiva
	else: #u svako drugom slucaju
		secondarygun.visible = false #sekundarna puska je nevidljiva
#-------------------------------------------------------------------------------
func fire():#Difinise se pucanje
	if current_weapon == 1:#ako je puska primarna
		$Control/Municija.set_text(str(primary_current_ammo) + "/" + str(primarygun.broj_metaka)) #ispisuje broj municije na ekranu
		if Input.is_action_pressed("fire") and can_fire: #ako se pritisne drzi klik i ako moze da puca
			can_switch = false #ne moze da se menja oruzije dok pucas
			if primary_current_ammo > 0 and not reloading: #ako je broj metaka veci od 0 i ne reloaduje
				anim_player.play("PrimaryPucanje") #startuje se animacija za pucanje
				if ray_cast.is_colliding():	 #ako se raycast sudari
					bullet = metak.instance() #definise se bullet/metak
					ispucaj.add_child(bullet) #na mesto muzzle-a se stvara bullet
					bullet.look_at(ray_cast.get_collision_point(),Vector3.UP) #pravac metka
					bulletbas = bullet.transform.basis
					bullet.transform.basis = Basis(bulletbas.x.normalized()/10, bulletbas.y.normalized()/10, bulletbas.z.normalized()/10)
					bullet.shoot() #ispaljuje se metak
					can_fire = false #definise se da ne moze da puca
					primary_current_ammo -= 1 #oduzima se jedan metak
					yield(get_tree().create_timer(primarygun.fire_rate), "timeout")#pauza izmedju metaka
					can_fire = true #definise se da moze da puca
					can_switch = true
#---------------------------RELOAD PRVE PUSKE-----------------------------------
		elif primary_current_ammo == 0 or Input.is_action_pressed("reloading") and primary_current_ammo < primarygun.broj_metaka : #ako je municija jednaka nuli ili ako je kliknuto da se reloaduje
			can_switch = false #ne moze da se menja oruzije
			anim_player.play("PrimaryReload")#startuje se animacija za reload
			reloading = true #reloaduje
			yield(get_tree().create_timer(primarygun.reload_size), "timeout") #pauza za reloadovanje
			primary_current_ammo = primarygun.broj_metaka #postavlja se broj metaka na maksimalni broj metaka primarne puske
			reloading = false #ne reloaduje
			can_switch = true #moze da se menja oruzije
#----------------------------DRUGA PUSKA----------------------------------------			
	if current_weapon == 2: #ako je puska sekundarna
		$Control/Municija.set_text(str(secondary_current_ammo) + "/" + str(secondarygun.broj_metaka)) #ispisuje broj municije na ekranu
		if Input.is_action_just_pressed("fire") and can_fire: #ako se pritisne levi klik
			can_switch = false
			if secondary_current_ammo > 0 and not reloading: #ako je broj metaka veci od nule i ne reloaduje
				if ray_cast.is_colliding():	 #ako se raycast sudari
					bullet = metak.instance() #definise se bullet/metak
					ispucaj.add_child(bullet) #na mesto muzzle-a se stvara bullet
					bullet.look_at(ray_cast.get_collision_point(),Vector3.UP)#pravac metka
					bulletbas = bullet.transform.basis
					bullet.transform.basis = Basis(bulletbas.x.normalized()/10, bulletbas.y.normalized()/10, bulletbas.z.normalized()/10)
					bullet.shoot()#ispaljuje se metak
					anim_player.play("SecondaryPucanje")
					secondary_current_ammo -= 1 #oduzima se jedan metak
#-----------------------------RELOAD DRUGE PUSKE--------------------------------
		elif secondary_current_ammo == 0 or Input.is_action_just_pressed("reloading") and secondary_current_ammo < secondarygun.broj_metaka: #ako je broj metaka jednak nuli ili ako je kliknuto da se reloaduje 
				can_switch = false
				anim_player.play("SecondaryReload")
				reloading = true #reloaduje
				secondary_current_ammo = secondarygun.broj_metaka #postavlja broj metaka na maksimalni broj metaka sekundarne puske
				yield(get_tree().create_timer(secondarygun.reload_size), "timeout") #pauza za reload
				reloading = false #ne reloaduje 
				can_switch = true
#-------------------------------------------------------------------------------
func _input(event): #za rotiranje kamere
	if event is InputEventMouseMotion and play:#definise se rotiranje kamere
		rotate_y(-event.relative.x * sens)
		pivot.rotate_x(-event.relative.y * sens)
		pivot.rotation.x = clamp(pivot.rotation.x, deg2rad(-90),deg2rad(90))
#-------------------------------------------------------------------------------
func _process(delta):
	guncam.global_transform = camera.global_transform #definise se da lokacija gun kamere bude ista kao glavna kamera
#-------------------------------------------------------------------------------
func _physics_process(delta):
	if Input.is_action_pressed("fire"):
		can_switch = false
	else:
		can_switch = true
	weapon_select()
	fire()#poziva se pucanje
	if Input.is_action_pressed("ui_cancel"):#ako se drzi cancel vidi se strelica
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	#else:#u svakom drugom slucaju da se sakrije strelica
		#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#---------------------------------------------------------------------------
	var basis = global_transform.basis #definise se basis
	dir = Vector3.ZERO #definise se pravac
	#---------------------------------------------------------------------------
	#definise se u kom pravcu se krece
	if Input.is_action_pressed("napred"):
		dir-=basis.z
	if Input.is_action_pressed("nazad"):
		dir+=basis.z
	if Input.is_action_pressed("levo"):
		dir-=basis.x
	if Input.is_action_pressed("desno"):
		dir+=basis.x
	dir = dir.normalized() #normalizuje se pravac/dodeljuje mu se vrednost 1
	#---------------------------------------------------------------------------
	if Input.is_action_pressed("run") and can_run:#ako se drzi ctrl da mu se poveca brzina
		speed = runspeed #brzina ce biti jednaka brzini trcanja
	elif Input.is_action_pressed("crouch"):
		speed = crouchspeed
		can_run = false
	else:
		speed = walkspeed
		can_run = true
	#------------------CROUCH---------------------------------------------------
	if Input.is_action_pressed("crouch"):
		self.scale = crouch_height
	else:
		self.scale = default_height
	#------------------------JUMP-----------------------------------------------
	if is_on_floor():
		velocity.y = 0 #da normalno bude na visini 0
		if Input.is_action_pressed("jump"):#ako se pritisne space da skoci
			velocity.y = jump #igrac ce se pomeriti na y-osi za onoliko koliko je definisan jump
	else:
		velocity.y += gravity * delta #definise se gravitacija
	#---------------------------------------------------------------------------
	var kretanje = dir*speed#definise se u kom ce pravcu da se krece i kojom brzinom
	#---------------------------------------------------------------------------
	$Control/FPS.set_text("FPS: " +str(Performance.get_monitor(Performance.TIME_FPS)))
	$Control/Memory.set_text("Memory Static: " + str(round(Performance.get_monitor(Performance.MEMORY_STATIC)/1024/1024)) + " MB")
	$Control/Brzina.set_text("Brzina: " + str(speed)) #ispisuje brzinu na ekranu
	#---------------------------------------------------------------------------
	kretanje=kretanje.linear_interpolate(dir, delta)
	velocity.x = kretanje.x
	velocity.z = kretanje.z
	#---------------------------------------------------------------------------
	if play:#pokrece igru
		velocity = move_and_slide(velocity,Vector3.UP, true) #ovo true je da se ne kliza ali ne radi
#-------------------------------------------------------------------------------
func _on_Provalija_body_entered(body): #ako igrac udje u provalija 
	get_tree().change_scene("res://Scene/Svet.tscn")
