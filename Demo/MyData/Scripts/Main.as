Scene@ scene_;
Node@ lightNode_;
Node@ horseNode_;

void Start()
{
    renderer.hdrRendering = true;
    renderer.shadowMapSize = 2048;
    renderer.shadowQuality = SHADOWQUALITY_PCF_16BIT;

    scene_ = Scene();
    scene_.CreateComponent("Octree");
    
    Zone@ zone = scene_.CreateComponent("Zone");
    zone.boundingBox = BoundingBox(-1000.0f, 1000.0f);
    zone.ambientColor = Color(0.4f, 0.4f, 0.4f);

    lightNode_ = scene_.CreateChild();
    lightNode_.direction = Vector3(0.5f, -0.5f, 0.5f);
    Light@ light = lightNode_.CreateComponent("Light");
    light.lightType = LIGHT_DIRECTIONAL;
    light.brightness = 0.8f;
    light.castShadows = true;
    light.shadowCascade = CascadeParameters(10.0f, 50.0f, 100.0f, 0.0f, 0.8f);

    Node@ cameraNode = scene_.CreateChild();
    Camera@ camera = cameraNode.CreateComponent("Camera");
    cameraNode.position = Vector3(0.0f, 15.0f, -15.0f);
    cameraNode.LookAt(Vector3(0.0f, 5.0f, 0.0f));
    
    Viewport@ viewport = Viewport(scene_, camera);
    viewport.renderPath.Append(cache.GetResource("XMLFile", "PostProcess/BloomHDR.xml"));
    viewport.renderPath.Append(cache.GetResource("XMLFile", "PostProcess/FXAA3.xml"));
    renderer.viewports[0] = viewport;

    Node@ planeNode = scene_.CreateChild();
    planeNode.position = Vector3(0.0f, 0.0f, 25.0f);
    planeNode.Scale(100.0f);
    StaticModel@ planeObject = planeNode.CreateComponent("StaticModel");
    planeObject.model = cache.GetResource("Model", "Models/Plane.mdl");
    planeObject.material = cache.GetResource("Material", "Materials/StoneTiled.xml");
    
    horseNode_ = scene_.CreateChild();
    horseNode_.rotation = Quaternion(0.0f, 30.0f, 0.0f);
    StaticModel@ horseObject = horseNode_.CreateComponent("StaticModel");
    horseObject.model = cache.GetResource("Model", "Models/abaddon_mount.mdl");
    horseObject.ApplyMaterialList();
    horseObject.castShadows = true;

    SubscribeToEvent("Update", "HandleUpdate");
}

void HandleUpdate(StringHash eventType, VariantMap& eventData)
{
    float timeStep = eventData["TimeStep"].GetFloat();
    IntVector2 mouseMove = input.mouseMove;
    horseNode_.Rotate(Quaternion(0.0f, -timeStep * mouseMove.x * 5.0f, 0.0f));
    lightNode_.Rotate(Quaternion(0.0f, 10.0f * input.mouseMoveWheel, 0.0f), TS_WORLD);
    
    if (input.keyDown[KEY_ESC])
        engine.Exit();
}

