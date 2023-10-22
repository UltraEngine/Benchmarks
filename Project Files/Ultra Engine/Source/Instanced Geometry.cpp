#include "UltraEngine.h"

using namespace UltraEngine;

int main(int argc, const char* argv[])
{
	const int count = 32;

    //Get the displays
    auto displays = GetDisplays();
	 
    //Create a window
    auto window = CreateWindow("Instanced Geometry", 0, 0, 1280, 720, displays[0], WINDOW_CENTER | WINDOW_TITLEBAR);

	//Create framebuffer
	auto framebuffer = CreateFramebuffer(window);

    //Create world
    auto world = CreateWorld();

	//Create camera
	auto camera = CreateCamera(world);
	camera->SetPosition(0, 0, -count * 2);
	camera->SetClearColor(0.125);
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
	boxes.reserve(count * count * count);
	int x, y, z;
	for (x = 0; x < 32; ++x)
	{
		for (y = 0; y < 32; ++y)
		{
			for (z = 0; z < 32; ++z)
			{
				auto inst = box->Instantiate(world);
				inst->SetPosition(3.0f + float(x - 1 - (count / 2)) * 2, 3.0f + float(y - 1 - (count / 2)) * 2, 3.0f + float(z - 1 - (count / 2)) * 2);
				boxes.push_back(inst);
			} 
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
