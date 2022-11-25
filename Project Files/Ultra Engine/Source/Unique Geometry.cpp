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

	//Create box
	auto box = CreateBox(world);
	box->SetCollider(NULL);

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

	//Main loop
	while (window->Closed() == false and window->KeyDown(KEY_ESCAPE) == false)
	{
		world->Update();
		world->Render(framebuffer, false);
	}
	return 0;
}
