hp_sum_push Cookbook
======================
This cookbook will perform the HP SUM firmware update from a given SPP baseline. The cookbook utilises hpsum's centralized model to push the firmware and software to non-Chef client devices (~40 max). 

The use model is to access the HP SUM software and the baseline over NFS. The cookbook
will mount the NFS mount points provided by the attributes settings.

If the HP SUM NFS mount is "read-write", the HP SUM executables will run locally over the network. If the mount is "read-only",
a copy of HP SUM will be stored on the local server, under a directory defined, and will then
execute HP SUM from the local store. The local store of HP SUM software can then be re-used on
subsequent runs.

Requirements
------------
NFS available filesystem of HP SUM software.

NFS avaliable filesystem of Firmware baseline.

NFS filesystems exported as use model requirements i.e. read-write or read-only

Attributes configured as required.

Update the hpsum.in.erb file with the desired HP SUM options.

Create data bags (for each hub Chef client) containing the node, user and password for each managed device. For example, the Chef client is "chefdomain", the managed device is called "puppetclient2":

{
  "id": "16.83.62.253",
  "user": "root",
  "password": "xxxxxxxx"
}


Attributes
----------

#### hp_sum_push::default

<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['hpsum']['nfs']['locallocation']</tt></td>
    <td>String</td>
    <td>Local server mount point for the HP SUM software</td>
    <td><tt>"mountpoint"</tt></td>
  </tr>
  <tr>
    <td><tt>['hpsum']['nfs']['remotelocation']</tt></td>
    <td>String</td>
    <td>Remote NFS server and exported filesystem for HP SUM software</td>
    <td><tt>"server:exported filesystem"</tt></td>
  </tr>
  <tr>
    <td><tt>['hpsum']['nfs']['type']</tt></td>
    <td>String</td>
    <td>HP SUM NFS mount type</td>
    <td><tt>"rw", "ro", or "local"</tt></td>
  </tr>
  <tr>
    <td><tt>['hpsum']['local']['clean']</tt></td>
    <td>String</td>
    <td>Clean local store repository before and after run</td>
    <td><tt>"nil" or "true"</tt></td>
  </tr>
  <tr>
    <td><tt>['hpsum']['local']['directory']</tt></td>
    <td>String</td>
    <td>Local store repository for copying HP SUM to server</td>
    <td><tt>"Directory"</tt></td>
  </tr>
  <tr>
    <td><tt>['hpsum']['baseline']['localfs']</tt></td>
    <td>String</td>
    <td>Local server mount point for firmware baseline</td>
    <td><tt>"mountpoint"</tt></td>
  </tr>
  <tr>
    <td><tt>['hpsum']['baseline']['remotefs']</tt></td>
    <td>String</td>
    <td>Remoe NFS server and exported filesystem for Firmware baseline</td>
    <td><tt>"server:exported filesystem"</tt></td>
  </tr>
</table>

Usage
-----
#### hp_sum_push::default

Call `hp_sum_push` from wrapper cookbook which is then added to the server's `run_list`:

Contributing
------------
(optional) If this is a public cookbook, detail the process for contributing. If this is a private cookbook, remove this section.

e.g.
1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write your change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

License and Authors
-------------------
Authors: Robin Hart
