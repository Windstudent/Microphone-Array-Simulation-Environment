function micPos = generateUlaCoords(nodePos,nMic,spacing,dir,height)

tmpX = (0:nMic-1)*spacing-(nMic-1)*spacing/2;
tmpY = zeros(1,nMic);
tmp = [tmpX;tmpY];

rotMat = [cosd(dir),-sind(dir);sind(dir),cosd(dir)];

tmpRot = rotMat*tmp;
micPos(1:2,:) = tmpRot+nodePos(1:2,1)*ones(1,nMic);
micPos(3,:) = height;

end    
