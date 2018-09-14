#!/bin/bash

virsh destroy simulation_server01
virsh destroy simulation_server02
virsh destroy simulation_server03
virsh destroy simulation_server04

virsh start simulation_server04
virsh start simulation_server03
virsh start simulation_server02
virsh start simulation_server01
