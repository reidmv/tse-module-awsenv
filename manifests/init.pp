# This is the example awsdemo module
# you need to write a profile for this to work
# with the profile written, you could then call 'puppet apply your_profile.pp'
# from any machine with this module installed and get a working PE demo env
class awsenv (
  $availability_zone,
  $region,
  $aws_keyname,
  $created_by,
  $project,
  $department,
  $master_iam_profile,
  $image_ids,
  $master_instance_type = 'm4.xlarge',
  $pe_build = 'latest',
  $vpc_mask    = '10.90.0.0',
  $zone_a_mask = '10.90.10.0',
  $zone_b_mask = '10.90.20.0',
  $zone_c_mask = '10.90.30.0',
) {
  $pe_admin_password = 'puppetlabs'

  notify {"PE Admin console initial password is: ${pe_admin_password}": }

  awsenv::vpc { "${department}-${region}":
    region      => $region,
    department  => $department,
    vpc_mask    => $vpc_mask,
    zone_a_mask => $zone_a_mask,
    zone_b_mask => $zone_b_mask,
    zone_c_mask => $zone_c_mask,
    created_by  => $created_by,
  }
  awsenv::nodes::pe { "${project}-${department}-${region}-${created_by}-master":
    availability_zone => $availability_zone,
    image_id          => $image_ids[$region]['centos7'],
    region            => $region,
    instance_type     => $master_instance_type,
    security_groups   => [
      "${department}-${region}-master",
      "${department}-${region}-crossconnect"
    ],
    subnet            => "${department}-${region}-avza",
    department        => $department,
    project           => $project,
    created_by        => $created_by,
    key_name          => $aws_keyname,
    pe_admin_password => $pe_admin_password,
    pe_role           => 'aio',
    pe_build          => $pe_build,
    pe_dns_altnames   => 'master',
    iam_profile       => $master_iam_profile,
    require           => Awsenv::Vpc["${department}-${region}"]
  }
}
