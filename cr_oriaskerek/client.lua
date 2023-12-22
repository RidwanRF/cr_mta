local sx, sy = guiGetScreenSize();
local lps = { x = 384.96310, y = -2032.07642, z = 7.83594, rz = 90 };  -- Position where player will be teleported after he leaves a cabin
local bdKey = { 'E', 'E' };                                      -- Keys to get inside [1] and outside [2] of the cabin ('K' and 'L' by default)
local tstgs = {
  text = "Nyomd meg az '"..bdKey[ 1 ].."' betűt a beszálláshoz.",       -- Text that will show up when cabin gets closer to a player
  font = 'bankgothic',                                           -- Text font (can be a custom font too)
  scale = 0.7,                                                   -- Text scale
  color = tocolor( 255, 255, 255, 255 ),                         -- Text color
  shadow = tocolor( 0, 0, 0, 255 )                               -- Text shadow color
};

addEventHandler( 'onClientResourceStart', resourceRoot, function()
  engineReplaceCOL( engineLoadCOL( 'fcabin.col' ), 3752 );
  triggerServerEvent( 'client_getCabinsCollision', localPlayer );
end );

addEventHandler( 'onClientResourceStop', resourceRoot, function()
  setCameraClip( true, true );
end );

addEventHandler( 'onClientElementStreamIn', root, function()
  if getElementModel( source ) == 3752 then
    engineReplaceCOL( engineLoadCOL( 'fcabin.col' ), 3752 );
  end;
end );

addEvent( 'server_sendCabinsCollision', true );
addEventHandler( 'server_sendCabinsCollision', root, function( t )
  for i, col in ipairs( t ) do
    addEventHandler( 'onClientColShapeHit', col, function( player, dim )
      if player == localPlayer and dim then
        bindKey( bdKey[ 1 ], 'down', getInside, col );
        colorCode = exports['cr_core']:getServerColor(nil, true)
        tstgs.text = "A beszálláshoz használd a(z) '"..colorCode..bdKey[ 1 ].."#ffffff' billentyűt!";
        addEventHandler( 'onClientRender', root, drawNotice );
        setCameraClip( false, true );
      end;
    end );
    
    addEventHandler( 'onClientColShapeLeave', col, function( player, dim )
      if player == localPlayer and dim then
        removeEventHandler( 'onClientRender', root, drawNotice );
        unbindKey( bdKey[ 1 ], 'down', getInside );
        unbindKey( bdKey[ 2 ], 'down', leaveCabin );
        setCameraClip( true, true );
      end;
    end );
  end;
end );

addEventHandler( 'onClientPlayerWasted', localPlayer, function()
  unbindKey( bdKey[ 1 ], 'down', getInside );
  unbindKey( bdKey[ 2 ], 'down', leaveCabin );
  removeEventHandler( 'onClientRender', root, drawNotice );
end );

function drawNotice()
    font = exports['cr_fonts']:getFont("Roboto", 11)
    colorCode = exports['cr_core']:getServerColor(nil, true)
    
    local text = tstgs.text
    local width = dxGetTextWidth(text, 1, font, true) + 20
    local height = dxGetFontHeight(1, font) + 10
    
    dxDrawRectangle(sx/2 - width/2, 50 - height/2, width, height, tocolor(0,0,0,180))
    dxDrawText(text, sx/2, 50, sx/2, 50, tocolor(255,255,255,255),1, font, "center", "center", false, false, false, true)
end;

function getInside( key, state, col )
  local x, y, z = getElementPosition( col );
  setElementPosition( localPlayer, x - 0.5, y, z );
  
    colorCode = exports['cr_core']:getServerColor(nil, true)
  tstgs.text = "A kiszálláshoz használd a(z) '"..colorCode..bdKey[ 2 ].."#ffffff' billentyűt!";
  unbindKey( bdKey[ 1 ], 'down', getInside );
  bindKey( bdKey[ 2 ], 'down', leaveCabin );
end;

function leaveCabin( key, state )
  setElementPosition( localPlayer, lps.x, lps.y, lps.z );
  setElementRotation( localPlayer, 0, 0, lps.rz );
  unbindKey( bdKey[ 2 ], 'down', leaveCabin );
end;