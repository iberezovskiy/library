#!/bin/bash

projects_file=${1:-"projects.txt"}
packages_file=${2:-"packages.txt"}

dot_dir="DEB_Tree/dot"
png_dir="DEB_Tree/png"
mkdir -p ${dot_dir} ${png_dir}

for project in $(cat ${projects_file}); do

  echo -e 'digraph "openstack-graph" {
        rankdir=LR;
        concentrate=true;
        node [shape=box];' > ${dot_dir}/${project}.dot

  for i in $(cat ${packages_file} | grep ${project}); do

    debtree --condense --no-alternatives --no-conflicts --no-recommends --no-provides --no-versions --with-suggests ${i} > tmp_file

    if [ $? -ne '0' ]; then
      echo $i >> no_deps
    else
      for line in $(cat ${packages_file}); do
        grep -E "\".*\" -> \"${line}\"" tmp_file;
      done >> ${dot_dir}/${project}.dot
    fi

    if [ "${project}" != "${i}" ]; then
      echo -e "\t\"${project}\" -> \"${i}\" [color=blue];" >> ${dot_dir}/${project}.dot
      echo -e "\t\"${i}\" [style=\"setlinewidth(2)\"];" >> ${dot_dir}/${project}.dot
    fi
  done

  echo -e "\t\"${project}\" [style=\"setlinewidth(2)\"];" >> ${dot_dir}/${project}.dot
  echo -e '}' >> ${dot_dir}/${project}.dot

  dot -T png -o ${png_dir}/${project}.png ${dot_dir}/${project}.dot

  rm tmp_file

done
