n_scenes = 100; % Number of scenes
n_neighbour = 50; % Number of neighbour for aligning the scenes
%Usually the more the better, we find using 300 works well for 5000~8000
%scenes

dess = dess_batch_processing(output);
G = similarity_graph(dess, n_neighbour);
pairstruct = all_pairwise_alignment(output, G);
topt = translation_sync(pairstruct);
rotIds = rotation_sync(n_scenes, pairstruct);
newoutput = transform_scenes(output, rotIds, topt);