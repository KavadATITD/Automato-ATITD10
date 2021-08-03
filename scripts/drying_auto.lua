dofile("common.inc");
dofile("settings.inc");

-- Written by Tribisha July 2021
-- Version Log
-- v1.01: 
-- Bug fix > Added screen refresh to handle menu creep after first pass
-- Code efficiency > removed reliance on product flags in making loop
--                 > cleaned up unnecessary for-loops

arrangeWindows = true;
window_w = 246;
window_h = 184;
offset_w = 125; -- allow for wider window when drying sterile papyrus
offset_h = 25;

wmText = "Tap Ctrl on racks/hammocks to open and pin.\nTap Alt on racks/hammocks to open, pin and stash.";
askText = "Dry flax, grass or papyrus, without the mouse being used.\n\nWindow Manager will appear after options selected.";

function doit()
	askForWindow(askText);
	config();
		if(arrangeWindows) then
			windowManager("Racks Setup", wmText, false, true, window_w, window_h, nil, offset_w, offset_h);
			sleepWithStatus(500, "Starting... Don\'t move mouse!");
			unpinOnExit(start);
		else
	    start();
	  end
end

function start()
	for i=1, dryingPasses do
		-- refresh windows
		refreshWindows();
		srReadScreen();
		lsSleep(250);
		racks = findAllText("Dry " .. product);
		for j=1, #racks do
      clickText(racks[j]);
      lsSleep(100);
      clickMax();
      lsSleep(100);
    end
		lsSleep(250);
		closePopUp();  --If you don't have enough drying materials in inventory, then a popup will occur.
		checkMaking();
	end
		if(unpinWindows) then
			closeAllWindows();
		else
			refreshWindows();
		end;
	lsPlaySound("Complete.wav");
end

function config()
  scale = 0.8;
  local z = 0;
  local is_done = nil;
	-- Edit box and text display
	while not is_done do
		checkBreak("disallow pause");
		lsPrint(10, 10, z, scale, scale, 0xFFFFFFff, "Configure Drying Racks/Hammocks");
		local y = 40;

		dryingPasses = readSetting("dryingPasses",dryingPasses);
		lsPrint(10, y, z, scale, scale, 0xffffffff, "Passes:");
		is_done, dryingPasses = lsEditBox("dryingPasses", 100, y, z, 50, 30, scale, scale,
									   0x000000ff, dryingPasses);
		if not tonumber(dryingPasses) then
		  is_done = false;
		  lsPrint(10, y+30, z+10, 0.7, 0.7, 0xFF2020ff, "MUST BE A NUMBER");
		  dryingPasses = 1;
		end
		writeSetting("dryingPasses",tonumber(dryingPasses));
		y = y + 35;

		arrangeWindows = readSetting("arrangeWindows",arrangeWindows);
		arrangeWindows = CheckBox(10, y, z, 0xFFFFFFff, "Arrange windows", arrangeWindows, 0.65, 0.65);
		writeSetting("arrangeWindows",arrangeWindows);
		y = y + 32;


		if flax then
      flaxColor = 0x80ff80ff;
    else
      flaxColor = 0xffffffff;
    end
    if grass then
      grassColor = 0x80ff80ff;
    else
      grassColor = 0xffffffff;
    end
		if fertile then
      fertileColor = 0x80ff80ff;
    else
      fertileColor = 0xffffffff;
    end
		if sterile then
      sterileColor = 0x80ff80ff;
    else
      sterileColor = 0xffffffff;
    end

    flax = readSetting("flax",flax);
    grass = readSetting("grass",grass);
		fertile = readSetting("fertile",fertile);
		sterile = readSetting("sterile",sterile);

    if not grass and not fertile and not sterile then
      flax = CheckBox(15, y, z+10, flaxColor, " Dry Flax",
                           flax, 0.65, 0.65);
      y = y + 32;
    else
      flax = false
    end

    if not flax and not fertile and not sterile then
      grass = CheckBox(15, y, z+10, grassColor, " Dry Grass to Straw",
                              grass, 0.65, 0.65);
      y = y + 32;
    else
      grass = false
    end

		if not flax and not grass and not sterile then
      fertile = CheckBox(15, y, z+10, fertileColor, " Dry Fertile Papyrus",
                              fertile, 0.65, 0.65);
      y = y + 32;
    else
      fertile = false
    end

 		if not flax and not grass and not fertile then
      sterile = CheckBox(15, y, z+10, sterileColor, " Dry Sterile Papyrus",
                              sterile, 0.65, 0.65);
      y = y + 32;
    else
      sterile = false
    end

   writeSetting("flax",flax);
    writeSetting("grass",grass);
		writeSetting("fertile",fertile);
		writeSetting("sterile",sterile);

	if flax then
		product = "Rotten Flax";
		offset_w = 100;
  elseif grass then
	  product = "Grass";
		offset_w = 56;
  elseif fertile then
		product = "Papyrus";
		offset_w = 125;
  elseif sterile then
		product = "Sterile Papyrus";
		offset_w = 125;
  end

    if flax or grass or fertile or sterile then
    lsPrintWrapped(15, y, z+10, lsScreenX - 20, 0.7, 0.7, 0xd0d0d0ff,
                   "Uncheck box to see more options!");

      if lsButtonText(10, lsScreenY - 30, z, 100, 0x00ff00ff, "Begin") then
        is_done = 1;
      end
    end

	if lsButtonText(lsScreenX - 110, lsScreenY - 30, z, 100, 0xFF0000ff,
                    "End script") then
      error "Clicked End Script button";
    end

	lsDoFrame();
	lsSleep(tick_delay);
	end
end

function checkMaking()
	while 1 do
		refreshWindows();
		srReadScreen();
		drying = findAllText("drying");
			if #drying == 0 then       -- Finished making, now take the products
  		  clickAllText("Take");
			  lsSleep(100);
			  clickAllText("Everything");
			  lsSleep(50);
			  break; --We break this while statement because Making is not detect, hence we're done with this round
			end
		sleepWithStatus(999, "Waiting for " .. product .. " to dry", nil, 0.7, "Monitoring Pinned Window(s)");
	end
end

function refreshWindows()
  srReadScreen();
  this = findAllText("This");
	  for i = 1, #this do
	    clickText(this[i]);
	  end
  lsSleep(100);
end

function closePopUp()
  while 1 do
    srReadScreen()
    local ok = srFindImage("OK.png")
	    if ok then
	      statusScreen("Found and Closing Popups ...", nil, 0.7);
	      srClickMouseNoMove(ok[0]+5,ok[1]);
	      lsSleep(100);
	    else
	      break;
	    end
  end
end
