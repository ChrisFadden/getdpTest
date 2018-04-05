clc;
clear all;
close all;

meshFP = '/home/czf41/Documents/Sim_tools/Test_2D/mesh_anom';
f5_path = '/home/czf41/Github/getdpTest/SimParam/output.h5';

mesh = load_mesh(meshFP);

%Write the physical types
%physTypes = unique(mesh.region); %Get number of regions
physTypes = {pad('1_1_Background',19),pad('1_2_Scatterer',19),...
             pad('1_333_Source',19),pad('1_555_Sink',19),...
             pad('1_786_Bndry',19)};
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
   tags(ii) = mode([mesh.region(mesh.elements(ii,1));...
                    mesh.region(mesh.elements(ii,2));...
                    mesh.region(mesh.elements(ii,3))]);
    boundary = [mesh.bndvtx(mesh.elements(ii,1)),...
                mesh.bndvtx(mesh.elements(ii,2)),...
                mesh.bndvtx(mesh.elements(ii,3))];
    if(any(boundary))
       tags(ii) = 786; 
    end
    
    %Sources and Sinks (2D ONLY CURRENTLY)
    node1 = mesh.nodes(mesh.elements(ii,1),1:2);
    node2 = mesh.nodes(mesh.elements(ii,2),1:2);
    node3 = mesh.nodes(mesh.elements(ii,3),1:2);
    
    %Sources 
    for jj = 1:size(mesh.source.coord,1)
        srcCoord = mesh.source.coord(jj,:);
        if (all(node1 == srcCoord) || all(node2 == srcCoord) || all(node3 == srcCoord))
            tags(ii) = 333;
        end    
    end
    
    %Measurements
    for jj = 1:size(mesh.meas.coord,1)
        srcMeas = mesh.meas.coord(jj,:);
        if (all(node1 == srcMeas) || all(node2 == srcMeas) || all(node3 == srcMeas))
            tags(ii) = 555;
        end    
    end
           
end
hdf5write(f5_path,'Mesh/Elements/ElemType2/Tag',tags,'WriteMode','append');

