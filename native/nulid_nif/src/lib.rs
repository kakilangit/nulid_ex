use nulid::{DefaultGenerator, DistributedGenerator, Nulid};
use rustler::{Binary, Env, NewBinary, NifResult, Resource, ResourceArc};

struct GeneratorResource(DefaultGenerator);
struct DistributedGeneratorResource(DistributedGenerator);

#[rustler::resource_impl]
impl Resource for GeneratorResource {}

#[rustler::resource_impl]
impl Resource for DistributedGeneratorResource {}

fn nulid_from_binary(binary: Binary) -> NifResult<Nulid> {
    Nulid::try_from(binary.as_slice()).map_err(nulid_err_to_rustler)
}

fn nulid_to_binary<'a>(env: Env<'a>, nulid: &Nulid) -> Binary<'a> {
    let bytes = nulid.to_bytes();
    let mut bin = NewBinary::new(env, bytes.len());
    bin.as_mut_slice().copy_from_slice(&bytes);
    bin.into()
}

fn nulid_err_to_rustler(err: nulid::Error) -> rustler::Error {
    rustler::Error::Term(Box::new(format!("{err}")))
}

#[rustler::nif]
fn new() -> NifResult<String> {
    Nulid::new()
        .map(|id| id.to_string())
        .map_err(nulid_err_to_rustler)
}

#[rustler::nif]
fn new_binary<'a>(env: Env<'a>) -> NifResult<Binary<'a>> {
    let id = Nulid::new().map_err(nulid_err_to_rustler)?;
    Ok(nulid_to_binary(env, &id))
}

#[rustler::nif]
fn encode(binary: Binary) -> NifResult<String> {
    let nulid = nulid_from_binary(binary)?;
    Ok(nulid.to_string())
}

#[rustler::nif]
fn decode<'a>(env: Env<'a>, string: &str) -> NifResult<Binary<'a>> {
    let nulid: Nulid = string.parse().map_err(nulid_err_to_rustler)?;
    Ok(nulid_to_binary(env, &nulid))
}

#[rustler::nif]
fn nanos(binary: Binary) -> NifResult<u64> {
    let nulid = nulid_from_binary(binary)?;
    Ok(nulid.nanos() as u64)
}

#[rustler::nif]
fn millis(binary: Binary) -> NifResult<u64> {
    let nulid = nulid_from_binary(binary)?;
    Ok(nulid.millis() as u64)
}

#[rustler::nif]
fn random(binary: Binary) -> NifResult<u64> {
    let nulid = nulid_from_binary(binary)?;
    Ok(nulid.random())
}

#[rustler::nif]
fn is_nil(binary: Binary) -> NifResult<bool> {
    let nulid = nulid_from_binary(binary)?;
    Ok(nulid.is_nil())
}

#[rustler::nif]
fn generator_new() -> ResourceArc<GeneratorResource> {
    ResourceArc::new(GeneratorResource(DefaultGenerator::new()))
}

#[rustler::nif]
fn generator_generate(resource: ResourceArc<GeneratorResource>) -> NifResult<String> {
    resource
        .0
        .generate()
        .map(|id| id.to_string())
        .map_err(nulid_err_to_rustler)
}

#[rustler::nif]
fn generator_generate_binary<'a>(
    env: Env<'a>,
    resource: ResourceArc<GeneratorResource>,
) -> NifResult<Binary<'a>> {
    let id = resource.0.generate().map_err(nulid_err_to_rustler)?;
    Ok(nulid_to_binary(env, &id))
}

#[rustler::nif]
fn distributed_generator_new(node_id: u16) -> ResourceArc<DistributedGeneratorResource> {
    ResourceArc::new(DistributedGeneratorResource(
        DistributedGenerator::with_node_id(node_id),
    ))
}

#[rustler::nif]
fn distributed_generator_generate(
    resource: ResourceArc<DistributedGeneratorResource>,
) -> NifResult<String> {
    resource
        .0
        .generate()
        .map(|id| id.to_string())
        .map_err(nulid_err_to_rustler)
}

#[rustler::nif]
fn distributed_generator_generate_binary<'a>(
    env: Env<'a>,
    resource: ResourceArc<DistributedGeneratorResource>,
) -> NifResult<Binary<'a>> {
    let id = resource.0.generate().map_err(nulid_err_to_rustler)?;
    Ok(nulid_to_binary(env, &id))
}

rustler::init!("Elixir.Nulid.Native");
