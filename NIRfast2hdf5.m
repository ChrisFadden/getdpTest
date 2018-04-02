clc;
clear all;
close all;

meshFP = '/home/czf41/Documents/Sim_tools/Test_2D/mesh_anom';

f5_path = '/home/czf41/Documents/Sim_tools/Test_2D/test.h5';
f5_path2 = '/home/czf41/Github/getdpTest/build/output.h5';
%delete /home/czf41/Documents/Sim_tools/Test_2D/test.h5; %Remove file if it already exists...

mesh = load_mesh(meshFP);

%Write the physical types
%physTypes = unique(mesh.region); %Get number of regions
physTypes = {pad('1_1_Background',19),pad('1_2_Scatterer',19)};
hdf5write(f5_path,'Mesh/Physical Types',physTypes);

%Write the nodes
hdf5write(f5_path,'/Mesh/nodes',mesh.nodes','WriteMode','append');

%Write the elements

%numElements
hdf5write(f5_path,'Mesh/Elements/NumElements',size(mesh.elements,1),'WriteMode','append');

%Elements (all type 2 because NIR Fast)
hdf5write(f5_path,'Mesh/Elements/ElemType2/Nodes',mesh.elements','WriteMode','append');

%Create tags for elements
tags = ones(size(mesh.elements,1),1);
for ii = 1:length(tags) 
   tags(ii) = floor(mean([mesh.region(mesh.elements(ii,1));...
                    mesh.region(mesh.elements(ii,2));...
                    mesh.region(mesh.elements(ii,3))]));
    boundary = [mesh.bndvtx(mesh.elements(ii,1)),...
                mesh.bndvtx(mesh.elements(ii,2)),...
                mesh.bndvtx(mesh.elements(ii,3))];
    if(any(boundary))
       tags(ii) = 786; 
    end
end
hdf5write(f5_path,'Mesh/Elements/ElemType2/Tag',tags,'WriteMode','append');

