#include "UltraEngine.h"

using namespace UltraEngine;

int main(int argc, const char* argv[])
{
	//Get the displays
	auto displays = GetDisplays();

	//Create a window
	auto window = CreateWindow("Lighting", 0, 0, 1280, 720, displays[0], WINDOW_CENTER | WINDOW_TITLEBAR);

	//Create framebuffer
	auto framebuffer = CreateFramebuffer(window);

	//Create world
	auto world = CreateWorld();
	world->SetAmbientLight(0);

	//Create camera
	auto camera = CreateCamera(world);
	camera->SetClearColor(0.25);
	camera->Turn(45, 0, 0);
	camera->SetPosition(0, 25, -25);
	camera->SetDepthPrepass(false);

	//Create the ground
	auto ground = CreateBox(world, 80, 1, 80);
	ground->SetPosition(0, -0.5, 0);

	//Create lights
	std::vector<std::shared_ptr<Entity> > lights;
	lights.reserve(5 * 5);

	int x, y, z;
	for (x = 1; x <= 5; ++x)
	{
		for (z = 1; z <= 5; ++z)
		{
			auto inst = CreatePointLight(world);
			inst->SetRange(20);
			inst->SetPosition((x - 3) * 5, 10, (z - 3) * 5 + 10);
			lights.push_back(inst);
		}
	}

	//Create a scene
	auto model = CreateBox(world);
	model->SetCollider(NULL);
	std::vector<std::shared_ptr<Entity> > models;
	models.reserve(11 * 8 * 11);
	for (x = 1; x <= 11; ++x)
	{
		for (y = 1; y <= 8; ++y)
		{
			for (z = 1; z <= 11; ++z)
			{
				auto inst = model->Instantiate(world);
				inst->SetPosition((x - 6) * 2, y - 1, (z - 6) * 2 + 10);
				models.push_back(inst);
			}
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
