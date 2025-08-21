# Kali Linux Base image

This repo contains Packer files for building Kali Linux amd64 base image for QEMU/OpenStack using GitHub Actions.

## Image for QEMU/OpenStack

There are two user accounts:

*  `kali` with password `kali`, disabled for SSH
*  `debian` created by [cloud-init](https://cloudinit.readthedocs.io/en/latest/), enabled for SSH

## How to build

For information how to build this image see [wiki](https://github.com/cyberrangecz/images-wiki).

## License

This project is licensed under the [MIT License](LICENSE).

## Acknowledgements

<table>
  <tr>
    <td>![EU](figures/EU.jpg)</td>
    <td>
This software and accompanying documentation is part of a [project](https://cybersec4europe.eu) that has received funding from the European Union’s Horizon 2020 research and innovation programme under grant agreement No. 830929.
</td>
  </tr>
  <tr>
      <td>![TACR](figures/TACR.png)</td>
      <td>This software was developed with the support of the Technology Agency of the Czech Republic (TA ČR) from the National Centres of Competence programme (project identification TN01000077 – [National Centre of Competence in Cybersecurity](https://nc3.cz/)). 
      </td>
  </tr>
 </table>

