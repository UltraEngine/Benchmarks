#include "UltraEngine.h"

using namespace UltraEngine;

int main(int argc, const char* argv[])
{
	const int count = 64;

	//Get the displays
	auto displays = GetDisplays();

	//Create a window
	auto window = CreateWindow("Unique Geometry", 0, 0, 1280, 720, displays[0], WINDOW_CENTER | WINDOW_TITLEBAR);

	//Create framebuffer
	auto framebuffer = CreateFramebuffer(window);

	//Create world
	auto world = CreateWorld();
	world->SetAmbientLight(1);

	//Create camera
	auto camera = CreateCamera(world);
	camera->SetPosition(0, 0, -count);
	camera->SetClearColor(0.25);
	camera->SetDepthPrepass(false);

	//Create box
	auto box = CreateBox(world);
	box->SetCollider(NULL);

	auto mtl = CreateMaterial();
	mtl->SetColor(0.5f);
	mtl->SetShaderFamily(LoadShaderFamily("Shaders/Unlit.fam"));
	box->SetMaterial(mtl);

	//Create instances
	std::vector<shared_ptr<Entity> > boxes;
	boxes.reserve(count * count);
	int x, y;
	for (x = 0; x < 64; ++x)
	{
		for (y = 0; y < 64; ++y)
		{
			auto inst = box->Copy(world);
			inst->SetColor(Random(0.0f, 1.0f), Random(0.0f, 1.0f), Random(0.0f, 1.0f));
			inst->SetPosition(3.0f + float(x - 1 - (count / 2)) * 2, 3.0f + float(y - 1 - (count / 2)) * 2, 0);
			boxes.push_back(inst);
		}
	}
	box = NULL;

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
