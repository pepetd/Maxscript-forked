-- maj:
	-- ajouter outil pour rajouter un uvw map cubique
	-- importer la methode pour exploser les mesh avec multi material
	-- importer la m�thode pour fusionner les multimateriaux identiques dans la scene
	-- faire fonctionner le wirecolor sur une selection d'objet

fn sortMatbyname v1 v2 =
(
	-- qsort <array> sortbyname
-- 	vars
	local d
	
	if ( (toLower v1.name) < (toLower v2.name)) then
		d=-1
	else
		d=1
	
--compare les numeros entre eux et les classe	
	case of
	(
		(d < 0.): -1
		(d > 0.): 1
		default: 0
	)
)

fn convertMultiMat =
(
	multi = meditmaterials[activeMeditSlot]

	for i = 1 to multi.count do
	(
		if classof multi[i] == standard then
		(
			colref = multi[i].diffuse
			newMat = VRayMtl diffuse: colref name: multi[i].name
			multi[i] = newMat
		)
	)
)
-- convertMultiMat()

fn createMultiMat =
(
	meditmaterials[activeMeditSlot] = (multimaterial ())
)


fn tagMtlName tag=
(
	for m in scenematerials do
	(
		format "mat: %\n" m.name
		m.name =  tag + m.name
		format "mat: %\n" m.name
	)
)
-- tagMtlName "MATLOT_"

fn randomColorFN sel =
(
	randomColor = color (random 0 255) (random 0 255) (random 0 255)
	sel.wirecolor =  randomColor
)

fn randomWireFN useFirstId: true =
(
	for mat in sceneMaterials do 
	(
		randomWire = color (random 0 255) (random 0 255) (random 0 255) 
		sel = objects as array
		for o in sel do 
		(
			if (superclassof o == GeometryClass) do 
			(
				if (classof o.material) == multimaterial and useFirstId == true then
				(
-- 					print mat 
-- 					print o
					if o.material[1] == mat  do o.wirecolor = randomWire
				)
				else if  o.material == mat then
				(
					o.wirecolor = randomWire
				)
			)
		)
	)
)




fn addUVWCube uvSize =
(
	local UvModExist = True
	local UvwSquare = Uvwmap  maptype: 4 length: uvSize width: uvSize  height: uvSize  axis: 2
	
	modPanel.addModToSelection (UvwSquare) ui:on
)

fn addUVWCube2 uvSize =
(
	
	local UvwSquare = Uvwmap  maptype: 4 length: uvSize width: uvSize  height: uvSize  axis: 2
	
	for s in selection do
	(
		local UvModExist = false
		for m in s.modifiers do
		(
			if classof m == Uvwmap then
			(
				UvModExist = true
-- 				UvwSquare = m
				m.length = uvSize
				m.width = uvSize
				m.height = uvSize
			)
			else
			(
				addmodifier s UvwSquare
			)
		)
		
-- 		if not UvModExist then	modPanel.addModToSelection (UvwSquare) ui:on
		if not UvModExist then	addmodifier s UvwSquare -- ui:on
	)
	
	
)


-- make unique instance material
fn InstanceMatByName mat = (
	(for o in objects where o.mat != undefined and o.mat.name == mat.name collect o).mat = mat
)
 
-- collect id materials as array
fn idArrayDef s =
(
	local idArray = #()
	format "s: %\n" s
	local faceMax = s.GetNumFaces ()
	for i = 1 to faceMax do
	(
-- 		s.editablePoly.setSelection #face #{i}
		append idArray (s.editablePoly.GetFaceMaterial i)
	)
	return (sort(makeuniquearray idArray ))
)

-- explode mulitmat pour polygone
fn explodeMultiMatDef s matchMat: false=
(
	local idArray = idArrayDef s
	local multiMtl = s.material 
	local splitObjList = #(s)
	
	for id in idArray do
	(
		if id != 1 do
		(
			countBefore = objects.count
			s.selectByMaterial  id
			newName = uniquename (s.name + "_mat_" + (id as string))
			polyop.detachFaces s #selection delete: true asNode: true name: newName
			
			format "newNode: %\n"	newObj
			
			if matchMat then
			(
				local res = getnodebyname newName
				res.material = multiMtl[id]
				format "obj: %, \tmat: % \n" res.name multiMtl[id]
				append splitObjList res
			)
			
			
			-- copy/paste original modifier
			contAfter = objects.count
-- 			format "count"
			mf = for m in  s.modifiers collect m
			for i = (countBefore + 1) to objects.count do
			(
-- 				format "i :%\n" i
-- 				format "obj explode:%\n" objects[i]
				for m in s.modifiers do addmodifier objects[i] m
			)
			
		)
	)
	
	if matchMat then s.material = multiMtl[idArray[1]]
	format "explode material done: %\n" s
	splitObjList
)

-- explose meshes
fn getFacesID s =
(
	local idArray = #()
	local faceMax = meshop.getNumFaces s
	for i = 1 to faceMax do appendifunique idArray (getFaceMatID s i)
	idArray
)


-- refresh scenematerial
fn updateSceneMaterials =
 (
	 -- teste drive
	testAr = "jc"
	local drive
	 for i = 1 to testAr.count do
	(
		dir = getDirectories (testAr[i] + ":*")
		
		if dir.count > 0 then
		(
			drive = testAr[i]
			exit
		)
	)
	-- ecriture du filename
	 str = stringstream ""
	 format "%:/tmp.max" drive to: str
	 str as string
	
	saveNodes #() (str as string)
	deleteFile  (str as string)
	
-- 	saveNodes #() "c:/tmp.max"
-- 	deleteFile "c:/tmp.max"
 )
-- updateSceneMaterials()

 
fn skinMultiMatdef s =
(
-- for one object
	-- count multimaterial number

	
	multiTmp = s.material.count
	
	-- count objet id
	idMax = 0
	faceMax = s.GetNumFaces ()
	for i = 1 to faceMax do
	(
		polyop.setFaceSelection s i
		if (s.getMaterialIndex true) > idMax do idMax = s.getMaterialIndex true
	)
	polyop.setFaceSelection s #none
	print idMax
	
	tmpMat
	-- pour chaque id de l'objet a partir de 2:
	for i = 2 to idMax do
	(
		tmpMat = s.material
		-- detach faces with one material
		s.selectByMaterial  i
		newName = uniquename (s.name + "_mat_" + (i as string))
		polyop.detachFaces s #selection delete: false asNode: true name: newName
		
		newSkin = getnodebyname newName
		
		-- option: split edge by smoothing group
		-- appliquer un shell sur le nouvel objet
		-- faire un outline sur l'objet
		-- rename object by material
		-- apply unique matching material
		newSkin.material = tmpMat[i]
	)
	
-- 	s.material = tmpMat[1]
)


fn isolateByMat mat sel =
(
	clearselection()

	for s in sel do
	(
		if s.material == mat then
		(
			selectmore s
			s.ishidden = false
		)
		else
		(
			s.ishidden = true
		)
	)
)

fn countByMat mat sel =
(
	clearselection()
	local count  = 0
	for s in sel do
	(
		if s.material == mat then
		(
			count +=1
-- 			selectmore s
-- 			s.ishidden = false
		)
		else
		(
-- 			s.ishidden = true
		)
	)
	format "mat: % count: %\n" mat.name count
)



fn createVrMtl =
(
	meditMaterials[activeMeditSlot] = vraymtl()
)

fn createTile =
(
	meditMaterials[activeMeditSlot] = bricks()
)

-- remove materiel
fn removeMatDef =
(
	$.material = undefined
)


-- collect scene multimaterial
fn publishMatArray  matArray maxMatNum: 0 =
(
	local lastMatNum = maxMatNum + 24
	format "total: %, min: %, max: %\n" matArray.count maxMatNum lastMatNum 
	
	if  matArray.count  <= lastMatNum do
	(
		lastMatNum = matArray.count 
	)
	
	for i =  1 to 24 do
	(
		if matArray[i + maxMatNum] != undefined then
		(
			meditMaterials[i] = matArray[i + maxMatNum]
		)
		else
		(
			meditMaterials[i] = standard()
		)
	)
	
	#(matArray.count, lastMatNum)
)

fn collectClassOfMat classOfMat maxMatNum: 0 =
(
	local matArray = getclassinstances classOfMat target: scenematerials
	publishMatArray matArray maxMatNum: maxMatNum
)

fn collectMultiMatDef2 maxMatNum: 0 =
(
	local multimatArray = getclassinstances Multimaterial target: scenematerials
	publishMatArray multimatArray maxMatNum: maxMatNum
)

fn collectstandardMat maxMatNum: 0  =
(
	local standMatAr = getclassinstances standard target: sceneMaterials
	publishMatArray standMatAr maxMatNum: maxMatNum
)

fn publishSceneMatDef vrOnly: true  maxMatNum: 0 sortByName: false =
(
	local matToPubAr = #()

	-- collect scene material in array
	for i = 1 to sceneMaterials.count do
	(
		tmpMat = sceneMaterials[i]
		if classof tmpMat == vraymtl and vrOnly == true do
		(
			continue
		)
		append matToPubAr tmpMat
	)
	
	-- classe par ordre alphabetique
	if sortByName do qsort matToPubAr sortMatbyname 
	
	publishMatArray matToPubAr  maxMatNum: maxMatNum
)


fn collectMatFromSel sel maxMatNum: 0 =
(
	local matAr = #()
-- 	for s in sel do print s
	for s in sel where s.material != undefined do appendifunique matAr s.material 
	
	publishMatArray matAr maxMatNum: maxMatNum
)

-- showproperties meditmaterials[activemeditslot]

-- convert standard to vray
fn convertToVrMatDef mat =
(
	local converted = false
	local vrmat
	
	if classof mat == Standard then
	(
		vrMat = VRayMtl diffuse: mat.diffuse name: mat.name texmap_diffuse: mat.diffuseMap texmap_opacity: mat.opacityMap
		converted = true
		
	)
	else if classof mat == VRayMtl then (format "nothing to do\n")
	else if classof mat == Autodesk_Material then 
	(
		vrMat = VRayMtl name: mat.name
		
		
		if matchpattern (getPropNames mat)[1] pattern: "Generic_*" then
		(
			if hasProperty mat "Generic_Color" do vrMat.diffuse = mat.Generic_Color
			if hasProperty mat "Generic_Image" do vrMat.texmap_diffuse = mat.Generic_Image
			converted = true
		)
		else if matchpattern (getPropNames mat)[1] pattern: "Masonry_Color*" then
		(
			if hasProperty mat "Masonry_Color" do vrMat.diffuse = mat.Masonry_Color
			if hasProperty mat "Masonry_Color_Map" do vrMat.texmap_diffuse = mat.Masonry_Color_Map
			converted = true
		)
		else if matchpattern (getPropNames mat)[1] pattern: "Wall_Paint*" then
		(
			if hasProperty mat "Wall_Paint_Color" do vrMat.diffuse = mat.Wall_Paint_Color
			converted = true
		)
		else if matchpattern (getPropNames mat)[1] pattern: "Plastic_*" then
		(
			if hasProperty mat "Plastic_Color" do vrMat.diffuse = mat.Plastic_Color
			if hasProperty mat "Plastic_Color_Map" do vrMat.texmap_diffuse = mat.Plastic_Color_Map
			converted = true
		)
		else if matchpattern (getPropNames mat)[1] pattern: "Glazing_Custom*" then
		(
			vrMat.diffuse = mat.Glazing_Custom_Color
			vrMat.texmap_diffuse = mat.Glazing_Custom_Color_Map
			converted = true
		)
		else if matchpattern (getPropNames mat)[1] pattern: "Metal*" then
		(
			if matchpattern (getPropNames mat)[1] pattern: "Metallic*" then
			(
				vrMat.diffuse = mat.Metallic_Paint_Color
				vrMat.texmap_diffuse = mat.Metallic_Paint_Color_Map
			)
			else
			(
				vrMat.diffuse = mat.Metal_Color
			)
-- 			converted = true
		)
		else if matchpattern (getPropNames mat)[1] pattern: "Concrete*" then
		(
			vrMat.diffuse = mat.Concrete_Color
		)
		else if matchpattern (getPropNames mat)[1] pattern: "Wood*" then
		(
			vrMat.diffuse = mat.Wood_Stain_Color
			vrMat.texmap_diffuse = mat.Wood_Image
		)
		else if  matchpattern (getPropNames mat)[1] pattern: "Ceramic*" then
		(
			vrMat.diffuse = mat.Ceramic_Color
			vrMat.texmap_diffuse = mat.Ceramic_Color_Map
		)
		else if  matchpattern (getPropNames mat)[1] pattern: "Glazing_Type"  then
		(
			if hasProperty mat "Glazing_Color" do vrMat.diffuse = mat.Glazing_Color
			
-- 			vrMat.texmap_diffuse = mat.Ceramic_Color_Map
		)
		else if matchpattern (getPropNames mat)[1] pattern: "Glazing_Color" then
		(
			if hasProperty mat "Glazing_Custom_Color" do vrMat.diffuse = mat.Glazing_Custom_Color
		)
		else if  matchpattern (getPropNames mat)[1] pattern: "Masonry_Type" then
		(
			vrMat.diffuse = mat.Masonry_Color
-- 			vrMat.texmap_diffuse = mat.Ceramic_Color_Map
		)
		
		else if  matchpattern (getPropNames mat)[1] pattern: "Wood_Image" then
		(
			vrMat.diffuse = mat.Wood_Stain_Color
			vrMat.texmap_diffuse = mat.Wood_Image
		)
		
		else
		(
		format "UNKNOW:%\n" (getPropNames mat)[1]
		showproperties 	mat
		)
		
		if not converted then 
		(
			format "UNKNOW:%\n" (getPropNames mat)[1]
			showproperties 	mat
		)
-- 		replaceinstances mat vrMat
-- 		meditMaterials[1] = vrMat
	)
	else (format "mat: % class: % \n" mat.name (classof mat) )
	
	if converted then replaceinstances mat vrMat 
	else if not converted and vrmat!= undefined then 
	(
		meditMaterials[1] = vrMat
		format "confirm mat: %\n" vrMat
	)
	else()
)
-- classof meditMaterials[activeMeditSlot]
--  meditMaterials[activeMeditSlot].Metal_Color
-- matchpattern (getPropNames meditMaterials[activeMeditSlot])[1] pattern: "Generic_*"
-- meditMaterials[activeMeditSlot].Generic_Color_Option
-- classof meditMaterials[activeMeditSlot]
-- hasProperty meditMaterials[activeMeditSlot] #Generic_Color

-- for p in getPropNames meditMaterials[activeMeditSlot] do
-- format "% = %\n" p (getProperty meditMaterials[activeMeditSlot] p)

-- function to return good smooth grp id
fn convertToSmoothGrpDef num =
(
	if num == 1 then
	(
		return 1
	)
	else
	(
		return (num^0.5 + 1)
	)
)

fn splitSmthGrpDef s =
(
	facesCount = s.editablepoly.ConvertSelection #object #Face

	smoothGroupAr = #()
	for i = 1 to facesCount do
	(
		smoothGroupId = s.editablepoly.GetFaceSmoothingGroups i
	-- 	print smoothGroupId
		append smoothGroupAr  smoothGroupId
	-- 	smoothGroupAr = makeuniquearray smoothGroupAr
	)
	smoothGroupAr = makeuniquearray smoothGroupAr
	print smoothGroupAr

	for o in smoothGroupAr do
	(
		smthGrp = convertToSmoothGrpDef o
		s.editablepoly.selectBySmoothGroup smthGrp
		s.editablepoly.ConvertSelectionToBorder #face #edge
		s.editablepoly.splitEdges()
	)
)
-- splitSmthGrpDef $



try(destroyDialog deMultiMatRLT)catch()
rollout deMultiMatRLT "Materials utilities"
(
	local lastManNum = 0
	
	
	group "wirecolor: "
	(
		button randColBT "random color"
		checkbox multiMatIDCB "use first id for multimaterial" checked: true
		button randomWireBT "wirecolor by material"
	)
	/*
	group "Multi-Materials:"
	(
		button collectMultiBT "collect multi-materials"
		button skinMatBT "skin multi-materials"
		button removeMatBT "remove material"
		button splitEdgeBT "split edges"
		
	)
	*/
	group "remove"
	(
		button removeMatBT "remove material"
	)
	
	group "explode multi-Materials:"
	(
		checkbox matchMatCB "match materials"
		button explodeBT "explode by material"
	)
	
	group "scene Materials:"
	(
		button refreshBT "refresh scene materials"
		checkbox vronlyCB "ignore vray materials"
		
		button publishSceneMatBT "publish scene materials"
		button listSceneMatBT "list scene materials"
	)
	
	group "class materials"
	(
-- 		button collectMultiBT "publish multi-materials"
-- 		button publishStandMatBT "publish standard materials"
		listbox matLB "mat class:" items: #("standard", "Multimaterial","Double_Sided", "vraymtl", "Autodesk_Material")
		button publishMatBT "publish"
	)
	
	group "rename:"
	(
		edittext prefixET "pref:"
		button addPrefBT "add"
	)
	
	group "Vray Material:"
	(
		button createVrMtlBT "create vray material"
		button convertToVrBT "convert to vray mat"
		button okConvertBT "confirm"
		button createMultiBT "create multi-mat"
-- 		button showBT "show properties"

-- 		button collectVrMtlBT "collect material"
-- 		button createTileBT "create tile"
	)
	
	group "collect materials... "
	(
		button collectSelMatBT " of the selection"
	)
	
	group "isolate sel medit material..."
	(
		button isolateByMatBT "in scene"
		button isolateByMat2BT "in visibles objects "
	)
	
	group "count sel medit material..."
	(
		button countBymatBT "in visibles objects "
	)
	
	group "count all medit material..."
	(
		button countAllmatBT "in visibles objects "
	)
	
	group "uvw mapping box:"
	(
		button uv100 "100" across: 3
		button uv250 "250"
		button uv500 "500"
	)
	
	
	on randColBT pressed do
	(
		for s in selection do randomColorFN s
	)
	
	on randomWireBT pressed do
	(
		randomWireFN useFirstId: multiMatIDCB.state
	)
	
	on collectMultiBT pressed do
	(
		local compare = collectMultiMatDef2 maxMatNum: lastManNum
		local sceneCount = compare[1]
		lastManNum = compare[2]
		if  lastManNum >= sceneCount then lastManNum = 0
	)
	
	on collectSelMatBT pressed do
	(
		sel = selection as array
-- 		collectMatFromSel sel
		
		local compare = collectMatFromSel sel maxMatNum: lastManNum
		local sceneCount = compare[1]
		lastManNum = compare[2]
		if  lastManNum >= sceneCount then lastManNum = 0
		
	)
	
	on explodeBT pressed do 
	(
		sel = selection as array
		
		for s in sel where classof s.material == multimaterial do
		(
			local returnTomesh = false
			if classof s == Editable_mesh then
			(
				converttopoly s
				returnTomesh = true
			)
			
			local splitObj = explodeMultiMatDef s  matchMat: matchMatCB.state
			
			if returnToMesh then
			(
				for o in splitObj do convertToMesh  o
			) else()
		)
	)
	
	on skinMatBT pressed do 
	(
		sel = selection as array
		for s in sel do
		(
			if (classof s.material) == multimaterial do
			(
				undo on
				(
					skinMultiMatdef s
				)
			)
		)
	)
	
	on splitEdgeBT pressed do
	(
		sel = selection as array
		
		for s in sel do
		(
			undo on
			(
				splitSmthGrpDef s
			)
		)
	)
	
	on removeMatBT pressed do removeMatDef()
	
	on  refreshBT pressed do 
	(
		lastManNum = 0
		updateSceneMaterials()
	)

	on publishSceneMatBT pressed do
	(
-- 		print "youhou"
		local compare = publishSceneMatDef vronly: vronlyCB.state maxMatNum: lastManNum sortbyname: true
		local sceneCount = compare[1]
		lastManNum = compare[2]
		if  lastManNum >= sceneCount then lastManNum = 0
		
-- 		print (format "compare : %\n" compare)
	)
	
	on listSceneMatBT pressed do
	(
		local matAr = for mat in scenematerials collect mat
		qsort matAr sortMatbyname
		for m in matAr do format "name: % class: %\n" m.name (classof m)
	)
	
	on publishStandMatBT pressed do
	(
		local compare = collectstandardMat maxMatNum: lastManNum
		local sceneCount = compare[1]
		lastManNum = compare[2]
		if  lastManNum >= sceneCount then lastManNum = 0
	)
	
	on publishMatBT pressed do
	(
		local classOfMat
-- 		format "sel: %\n"  matLB.selection
		
		if matLB.selection == 1 then  classOfMat = standard 
		else if  matLB.selection == 2 then classOfMat = multimaterial 
		else if  matLB.selection == 3 then classOfMat = DoubleSided
		else if  matLB.selection == 4 then classOfMat =	vraymtl
		else if  matLB.selection == 5 then classOfMat =	Autodesk_Material
		else(format "UNKNOW\n")
		
		local compare = collectClassOfMat classOfMat maxMatNum: lastManNum
		local sceneCount = compare[1]
		lastManNum = compare[2]
		if  lastManNum >= sceneCount then lastManNum = 0
	)
	
	on convertToVrBT pressed do 
	(
		convertToVrMatDef meditMaterials[activeMeditSlot]
	)
	
	on okConvertBT pressed do
	(
		replaceinstances meditMaterials[activeMeditSlot]  meditMaterials[1]
	)
	
	on createMultiBT pressed do
	(
		createMultiMat()
	)
	
	on showBT pressed do showproperties meditMaterials[activeMeditSlot]
	
	on publishSceneMat2BT pressed do publishSceneMatAdvDef()
	
	on createVrMtlBT pressed do createVrMtl()
	
	on createTileBT pressed do createTile()
	
	on addPrefBT pressed do
	(
		meditMaterials[activeMeditSlot].name = prefixET.text + "_" + meditMaterials[activeMeditSlot].name
	)
	
	on isolateByMatBT pressed do
	(
		sel = $* as array
		isolateByMat meditMaterials[activeMeditSlot] sel
	)
	
	on isolateByMat2BT  pressed do
	(
		sel =  for o in  $* where o.ishidden == false collect o
		isolateByMat meditMaterials[activeMeditSlot] sel
	)
	
	on countbyMatBT pressed do
	(
		sel =  for o in  $* where o.ishidden == false collect o
		countByMat meditMaterials[activeMeditSlot] sel
	)
	
	on countAllmatBT pressed do
	(
		sel =  for o in  $* where o.ishidden == false collect o
		mediMat = for m in meditMaterials collect m
		
		for i = 1 to medimat.count do
		(
			countByMat medimat[i] sel
			format "i: %\n" i
		)
	)
	
	on uv100 pressed do addUVWCube2 100
		
	on uv250 pressed do addUVWCube2 250
		
	on uv500 pressed do addUVWCube2 500
	
	
	
)
createdialog deMultiMatRLT

/*
sel = selection as array
withoutMatAr = for s in sel where s.material == undefined and superclassof s == GeometryClass collect s
select withoutMatAr
*/
