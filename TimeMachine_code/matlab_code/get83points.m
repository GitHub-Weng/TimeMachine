function get83points(landmark_points,photo)
    img = photo;
    img_width = size(img,2);
    img_height = size(img,1);
    landmark_names = fieldnames(landmark_points);
    fp = fopen('points/points2.lmk','w+');
     for j = 1 : length(landmark_names)
         pt = getfield(landmark_points, landmark_names{j});
         X = pt.x*img_width / 100;
         Y = pt.y*img_height / 100;
         fprintf(fp,'%6.2f %6.2f\r\n', [X,Y]');
     end
     fclose(fp);
end
