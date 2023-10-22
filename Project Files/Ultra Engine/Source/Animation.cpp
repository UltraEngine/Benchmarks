#include "UltraEngine.h"

using namespace UltraEngine;

int main(int argc, const char* argv[])
{
	//Get the displays
	auto displays = GetDisplays();

	//Create a window
	auto window = CreateWindow("Animation", 0, 0, 1280, 720, displays[0], WINDOW_CENTER | WINDOW_TITLEBAR);

	//Create framebuffer
	auto framebuffer = CreateFramebuffer(window);

	//Create world
	auto world = CreateWorld();
	world->SetAmbientLight(1);

	//Create camera
	auto camera = CreateCamera(world);
	camera->SetClearColor(0.25);
	camera->Turn(45, 0, 0);
	camera->SetPosition(0, 10, -20);
	camera->SetDepthPrepass(false);

	//Load model
	auto model = LoadModel(world, "Models/merc_lores.mdl");
	model->SetColor(0.8);
	auto mtl = CreateMaterial();
	mtl->SetTexture(LoadTexture("Models/merc_diff.dds"));
	mtl->SetShaderFamily(LoadShaderFamily("Shaders/Unlit.fam"));
	model->SetMaterial(mtl, true);

	//Create instances
	std::vector<std::shared_ptr<Entity> > models;
	models.reserve(32 * 32);
	int x, z;
	for (x = 1; x <= 32; ++x)
	{
		for (z = 1; z <= 32; ++z)
		{
			auto inst = model->Instantiate(world);
			inst->SetPosition((x - 16.5), 0, (z - 16.5));
			inst->As<Model>()->Animate(0, 1, 250, ANIMATION_LOOP, Random(1000));
			models.push_back(inst);
		}
	}
	model = NULL;

	//Fps display
	auto font = LoadFont("Fonts/arial.ttf");
	auto sprite = CreateSprite(world, font, "", 14);
	world->RecordStats(true);
	sprite->SetRenderLayers(2);
	sprite->SetPosition(2, framebuffer->size.y - font->GetHeight(14) - 2, 0);
	auto orthocam = CreateCamera(world, PROJECTION_ORTHOGRAPHIC);
	orthocam->SetRenderLayers(2);
	orthocam->SetClearMode(ClearMode(0));
	orthocam->SetPosition(float(framebuffer->size.x) * 0.5f, float(framebuffer->size.y) * 0.5f, 0);	
	
	//Main loop
	while (window->Closed() == false and window->KeyDown(KEY_ESCAPE) == false)
	{
		//Check for failed renderer initialization
		while (PeekEvent())
		{
			const auto e = WaitEvent();
			if (e.id == EVENT_STARTRENDERER and e.data == 0)
			{
				Notify(L"Renderer failed to intialize.\n\n" + e.text, "Ultra Engine", true);
				return 0;
			}
		}
		
		sprite->SetText("FPS: " + String(world->renderstats.framerate));
		
		world->Update();
		world->Render(framebuffer, false);
	}
	return 0;
}
