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
	
	//Load model
	auto model = LoadModel(world, "Models/merc_lores.mdl");
	model->SetColor(0.8);
	auto mtl = CreateMaterial();
	mtl->SetTexture(LoadTexture("Models/merc_diff.dds"));
	mtl->SetShaderFamily(LoadShaderFamily("Shaders/Unlit.json"));
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
			inst->As<Model>()->Animate(0);
			models.push_back(inst);
		}
	}
	model = NULL;

	//Main loop
	while (window->Closed() == false and window->KeyDown(KEY_ESCAPE) == false)
	{
		world->Update();
		world->Render(framebuffer, false);
	}
	return 0;
}
